class StarEvent < ApplicationRecord
  belongs_to :repository, primary_key: :name, foreign_key: :repo_name, optional: true

  scope :latest, ->(from) { where('starred_at >= ?', from) }
  scope :newly,  -> { order(starred_at: :desc) }
  scope :by,    ->(logins) { where(actor_login: logins) }
  scope :owner, ->(login) { where(repo_owner: login) }

  class << self
    # Group events by repository and order them by popularity.
    #
    # Returns an array of [repo_name, events, repository] tuples, where +events+
    # is ordered newest first.  Events whose repository is not stored yet are
    # excluded by the join, so every tuple has a repository.
    #
    # (actor_login, repo_name) is unique at the database level, so an actor
    # never appears twice within a group.
    def starred_ranking
      joins(:repository).includes(:repository).newly.to_a
        .group_by(&:repo_name)
        .sort_by {|_, events| [-events.count, -events.first.starred_at.to_i] }
        .map {|repo_name, events| [repo_name, events, events.first.repository] }
    end

    def each_with_repo
      includes(:repository).newly.each do |star_event|
        yield star_event, star_event.repository if star_event.repository
      end
    end
  end

  # The GitHub account that starred the repository.
  # Duck-types with Repository#owner and User so that view helpers can take
  # either of them.
  def actor
    Repository::Owner.new(login: actor_login, avatar_url: actor_avatar_url)
  end

  concerning :Fetchable do
    FETCH_CONCURRENCY = ENV.fetch('FETCH_CONCURRENCY', 5).to_i
    # Keep batches small enough to stay within GitHub's per-query resource
    # limit.  20 users × 30 repos × nested fields (owner, primaryLanguage)
    # routinely triggers RESOURCE_LIMITS_EXCEEDED;
    GRAPHQL_BATCH_SIZE = ENV.fetch('GRAPHQL_BATCH_SIZE', 5).to_i
    GRAPHQL_PAGE_SIZE = ENV.fetch('GRAPHQL_PAGE_SIZE', 10).to_i

    # One starred repository, normalized from either API shape.  The GraphQL
    # and the REST path return the same information under different names, so
    # they are converted here and share a single set of parsing rules from
    # then on.
    StarredRepository = Data.define(
      :starred_at,
      :private,
      :name,
      :description,
      :language,
      :stargazers_count,
      :owner_login,
      :owner_avatar_url
    ) do
      # A GraphQL StarredRepositoryEdge.
      def self.from_graphql_edge(edge)
        node = edge['node']

        new(
          starred_at:       Time.parse(edge['starredAt']),
          private:          node['isPrivate'],
          name:             node['nameWithOwner'],
          description:      node['description'],
          language:         node.dig('primaryLanguage', 'name'),
          stargazers_count: node['stargazerCount'],
          owner_login:      node.dig('owner', 'login'),
          owner_avatar_url: node.dig('owner', 'avatarUrl'),
        )
      end

      # An entry of Octokit::Client#starred requested with the star+json media
      # type, which wraps the repository in a starred_at / repo pair.
      def self.from_rest_item(item)
        repo       = item.repo
        starred_at = item.starred_at

        new(
          starred_at:       starred_at.is_a?(String) ? Time.parse(starred_at) : starred_at,
          private:          repo[:private],
          name:             repo.full_name,
          description:      repo.description,
          language:         repo.language,
          stargazers_count: repo.stargazers_count,
          owner_login:      repo.owner.login,
          owner_avatar_url: repo.owner.avatar_url,
        )
      end
    end

    class_methods do
      # Fetch star events using the GitHub GraphQL API.
      #
      # Batches multiple logins into a single HTTP request (GRAPHQL_BATCH_SIZE
      # users per call) using GraphQL field aliases.  This reduces the number of
      # HTTP round-trips from N_logins to N_logins/GRAPHQL_BATCH_SIZE.
      #
      # When a user has more starred repos than GRAPHQL_PAGE_SIZE within the
      # lookback window the method falls back to the REST path for that user,
      # keeping the happy-path lean while remaining correct.
      def fetch_and_upsert(token:, logins:, since:, debug: false, fallback_client: nil)
        require 'net/http'

        total = logins.size
        processed = 0
        needs_rest_fallback = []

        Rails.logger.info "[graphql] start: #{total} logins, batch_size=#{GRAPHQL_BATCH_SIZE}, page_size=#{GRAPHQL_PAGE_SIZE}, since=#{since}" if debug

        # Open a single persistent HTTPS connection for all batch requests.
        # Re-using one connection avoids repeated TLS handshakes and OpenSSL
        # context allocations (which can reach hundreds of MB when running
        # N_logins / GRAPHQL_BATCH_SIZE batches serially).
        Net::HTTP.start('api.github.com', 443, use_ssl: true, open_timeout: 15, read_timeout: 60) do |http|

          logins.each_slice(GRAPHQL_BATCH_SIZE) do |batch|
            processed += batch.size
            Rails.logger.info "[graphql] batch (#{processed}/#{total}): #{batch.size} logins" if debug

            started_at = Time.current
            result = execute_graphql_starred_batch(http, token, batch)
            elapsed = (Time.current - started_at).round(2)
            Rails.logger.info "[graphql] batch HTTP call took #{elapsed}s" if debug

            if (errors = result['errors'])
              Rails.logger.error "[graphql] top-level errors: #{errors.inspect}"
            end

            batch.each_with_index do |login, idx|
              user_data = result.dig('data', "u#{idx}")
              unless user_data
                Rails.logger.warn "[graphql] no data for @#{login} (u#{idx})" if debug
                next
              end

              edges     = user_data.dig('starredRepositories', 'edges') || []
              page_info = user_data.dig('starredRepositories', 'pageInfo') || {}

              star_events, repos, done = build_upsert_rows(
                login:                login,
                starred_repositories: edges.lazy.map {|edge| StarredRepository.from_graphql_edge(edge) },
                since:                since,
                debug:                debug,
                tag:                  'graphql'
              )

              upsert_events(star_events, debug)        unless star_events.empty?
              upsert_repositories(repos.values, debug) unless repos.empty?

              # If there are more pages and we have not yet reached `since`,
              # the REST path must fetch the remaining pages.
              if !done && page_info['hasNextPage']
                Rails.logger.info "[graphql] @#{login} has more pages – queued for REST fallback" if debug
                needs_rest_fallback << login
              end
            end

            GC.compact
          end
        end

        if needs_rest_fallback.any?
          Rails.logger.info "[graphql] REST fallback for #{needs_rest_fallback.size} logins" if debug
          client = fallback_client || Settings.github_client
          needs_rest_fallback.each_with_index do |login, idx|
            # upsert_all is idempotent, so re-fetching page 1 is safe.
            fetch_each_page(client, login, since, debug) do |star_events, repos|
              upsert_events(star_events, debug)
              upsert_repositories(repos, debug)
            end
            GC.compact if (idx + 1) % FETCH_CONCURRENCY == 0
          end
        end

        Rails.logger.info "[graphql] done" if debug
      end

      private

      # Turn normalized starred repositories into the rows expected by
      # upsert_events / upsert_repositories.  Both the GraphQL and the REST
      # path go through here, so the rules for what is stored and what is
      # skipped live in one place.
      #
      # Returns [star_events_array, repos_hash, done_boolean].
      # done is true once a repository older than `since` is reached; the list
      # is ordered newest first, so nothing behind it is relevant.  Callers
      # pass a lazy enumerator so that nothing past that point is parsed.
      def build_upsert_rows(login:, starred_repositories:, since:, debug:, tag:)
        actor_avatar_url = "https://github.com/#{login}.png"
        star_events = []
        repos       = {}
        done        = false

        starred_repositories.each do |starred|
          if starred.starred_at < since
            Rails.logger.info "[#{tag}] @#{login} reached since (#{starred.name} starred_at=#{starred.starred_at}), stopping" if debug
            done = true
            break
          end

          if starred.private
            Rails.logger.info "[#{tag}] @#{login} skipping private repo #{starred.name}" if debug
            next
          end

          Rails.logger.info "[#{tag}] @#{login} +#{starred.name} (starred_at=#{starred.starred_at})" if debug

          star_events << {
            actor_login:      login,
            actor_avatar_url: actor_avatar_url,
            repo_name:        starred.name,
            repo_owner:       starred.owner_login,
            starred_at:       starred.starred_at,
          }
          repos[starred.name] ||= {
            name:             starred.name,
            description:      starred.description,
            language:         starred.language,
            stargazers_count: starred.stargazers_count,
            owner_login:      starred.owner_login,
            owner_avatar_url: starred.owner_avatar_url,
          }
        end

        [star_events, repos, done]
      end

      # Execute a single batched GraphQL query that fetches the first page of
      # starred repos for every login in the slice.
      # http must be an already-open Net::HTTP connection to api.github.com.
      def execute_graphql_starred_batch(http, token, logins)
        aliases_str = logins.each_with_index.map do |login, idx|
          # Aliases must be valid GraphQL identifiers; use positional u0…uN.
          <<~GQL
            u#{idx}: user(login: #{login.to_json}) {
              starredRepositories(first: #{GRAPHQL_PAGE_SIZE}, orderBy: {field: STARRED_AT, direction: DESC}) {
                edges {
                  starredAt
                  node {
                    nameWithOwner
                    isPrivate
                    description
                    primaryLanguage { name }
                    stargazerCount
                    owner { login avatarUrl }
                  }
                }
                pageInfo { hasNextPage endCursor }
              }
            }
          GQL
        end.join

        execute_graphql(http, token, "query {\n#{aliases_str}}")
      end

      # POST a GraphQL query over an existing Net::HTTP connection and return
      # the parsed JSON body.  The caller is responsible for opening and closing
      # the connection; this keeps each call allocation-free with respect to
      # TCP / TLS setup.
      def execute_graphql(http, token, query)
        request = Net::HTTP::Post.new('/graphql')
        request['Authorization'] = "bearer #{token}"
        request['Content-Type']  = 'application/json'
        request['User-Agent']    = 'Starseeker'
        request.body             = { query: query }.to_json

        response = http.request(request)
        JSON.parse(response.body)
      end

      def fetch_each_page(client, login, since, debug)
        (1..).each do |page|
          Rails.logger.info "[fetch_each_page] @#{login} fetching page=#{page}" if debug

          starred = client.starred(
            login,
            sort: 'created',
            direction: 'desc',
            per_page: Octokit.per_page,
            page: page,
            headers: { accept: 'application/vnd.github.v3.star+json' }
          )

          Rails.logger.info "[fetch_each_page] @#{login} page=#{page}: #{starred.size} items" if debug
          break if starred.empty?

          star_events, repos, done = build_upsert_rows(
            login:                login,
            starred_repositories: starred.lazy.map {|item| StarredRepository.from_rest_item(item) },
            since:                since,
            debug:                debug,
            tag:                  'fetch_each_page'
          )

          Rails.logger.info "[fetch_each_page] @#{login} page=#{page}: yielding #{star_events.size} events" if debug
          yield star_events, repos.values unless star_events.empty?

          if done
            Rails.logger.info "[fetch_each_page] @#{login} stopped at since threshold" if debug
            break
          end

          if starred.size < Octokit.per_page
            Rails.logger.info "[fetch_each_page] @#{login} last page (#{starred.size} < #{Octokit.per_page})" if debug
            break
          end
        end
      end

      def upsert_events(star_events, debug)
        Rails.logger.info "[upsert_events] upserting #{star_events.size} star_events" if debug
        upsert_all(star_events, unique_by: [:actor_login, :repo_name])
        Rails.logger.info "[upsert_events] done" if debug
      end

      def upsert_repositories(repos, debug)
        Rails.logger.info "[upsert_repositories] upserting #{repos.size} repositories" if debug
        Repository.upsert_all(repos, unique_by: :name)
        Rails.logger.info "[upsert_repositories] done" if debug
      end
    end
  end
end
