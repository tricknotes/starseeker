class StarEvent < ApplicationRecord
  belongs_to :repository, primary_key: :name, foreign_key: :repo_name, optional: true

  scope :latest, ->(from) { where('starred_at >= ?', from) }
  scope :newly,  -> { order(starred_at: :desc) }
  scope :by,    ->(logins) { where(actor_login: logins) }
  scope :owner, ->(login) { where(repo_owner: login) }

  class << self
    def starred_ranking
      star_events = all.newly.to_a
      star_events = star_events.uniq { |e| [e.repo_name, e.actor_login].hash }

      grouped_events = star_events.group_by(&:repo_name)
      grouped_events = grouped_events.sort_by { |_, events| [-events.count, -events.first.starred_at.to_i] }
      grouped_events = grouped_events.filter_map do |repo_name, events|
        repo = events.first.repository
        [repo_name, events, repo] if repo
      end

      grouped_events
    end

    def each_with_repo
      includes(:repository).newly.each do |star_event|
        yield star_event, star_event.repository if star_event.repository
      end
    end
  end

  def created_at
    starred_at
  end

  concerning :Fetchable do
    FETCH_CONCURRENCY = ENV.fetch('FETCH_CONCURRENCY', 5).to_i
    # Keep batches small enough to stay within GitHub's per-query resource
    # limit.  20 users × 30 repos × nested fields (owner, primaryLanguage)
    # routinely triggers RESOURCE_LIMITS_EXCEEDED;
    GRAPHQL_BATCH_SIZE = ENV.fetch('GRAPHQL_BATCH_SIZE', 5).to_i
    GRAPHQL_PAGE_SIZE = ENV.fetch('GRAPHQL_PAGE_SIZE', 10).to_i

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
      def fetch_and_upsert_graphql(token:, logins:, since:, debug: false, fallback_client: nil)
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

              star_events, repos, done = parse_starred_edges(login, edges, since, debug)

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

      # Parse a list of GraphQL StarredRepositoryEdge hashes into the shape
      # expected by upsert_events / upsert_repositories.
      #
      # Returns [star_events_array, repos_hash, done_boolean]
      # done is true when the earliest edge in the slice predates `since`.
      def parse_starred_edges(login, edges, since, debug)
        actor_avatar_url = "https://github.com/#{login}.png"
        star_events = []
        repos       = {}
        done        = false

        edges.each do |edge|
          starred_at = Time.parse(edge['starredAt'])

          if starred_at < since
            Rails.logger.info "[graphql] @#{login} reached since (starred_at=#{starred_at}), stopping" if debug
            done = true
            break
          end

          node      = edge['node']
          if node['isPrivate']
            Rails.logger.info "[graphql] @#{login} skipping private repo #{node['nameWithOwner']}" if debug
            next
          end

          repo_name  = node['nameWithOwner']
          repo_owner = repo_name.split('/').first

          Rails.logger.info "[graphql] @#{login} +#{repo_name} (starred_at=#{starred_at})" if debug

          star_events << {
            actor_login:      login,
            actor_avatar_url: actor_avatar_url,
            repo_name:        repo_name,
            repo_owner:       repo_owner,
            starred_at:       starred_at,
          }
          repos[repo_name] ||= {
            name:             repo_name,
            description:      node['description'],
            language:         node.dig('primaryLanguage', 'name'),
            stargazers_count: node['stargazerCount'],
            owner_login:      repo_owner,
            owner_avatar_url: node.dig('owner', 'avatarUrl'),
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
        actor_avatar_url = "https://github.com/#{login}.png"

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

          star_events = []
          repos = {}
          done = false

          starred.each do |item|
            starred_at = item.starred_at.is_a?(String) ? Time.parse(item.starred_at) : item.starred_at

            if starred_at < since
              Rails.logger.info "[fetch_each_page] @#{login} reached since (#{item.repo.full_name} starred_at=#{starred_at}), stopping" if debug
              done = true
              break
            end

            repo = item.repo
            if repo[:private]
              Rails.logger.info "[fetch_each_page] @#{login} skipping private repo #{repo.full_name}" if debug
              next
            end

            Rails.logger.info "[fetch_each_page] @#{login} +#{repo.full_name} (starred_at=#{starred_at})" if debug

            star_events << {
              actor_login: login,
              actor_avatar_url: actor_avatar_url,
              repo_name: repo.full_name,
              repo_owner: repo.owner.login,
              starred_at: starred_at,
            }
            repos[repo.full_name] ||= {
              name: repo.full_name,
              description: repo.description,
              language: repo.language,
              stargazers_count: repo.stargazers_count,
              owner_login: repo.owner.login,
              owner_avatar_url: repo.owner.avatar_url,
            }
          end

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
