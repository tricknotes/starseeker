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

    class_methods do
      def fetch_and_upsert(client:, logins:, since:, debug: false)
        Rails.logger.info "[fetch_and_upsert] start: #{logins.size} logins, since=#{since}, concurrency=#{FETCH_CONCURRENCY}" if debug
        pool = Concurrent::FixedThreadPool.new(FETCH_CONCURRENCY)

        logins.each_slice(FETCH_CONCURRENCY) do |slice|
          futures = slice.map { |login|
            Concurrent::Future.execute(executor: pool) {
              started_at = Time.current
              Rails.logger.info "[fetch_and_upsert] fetching @#{login}" if debug

              fetch_each_page(client, login, since, debug) do |star_events, repos|
                upsert_events(star_events, debug)
                upsert_repositories(repos, debug)
              end

              elapsed = (Time.current - started_at).round(2)
              Rails.logger.info "[fetch_and_upsert] @#{login} done (#{elapsed}s)" if debug
            }
          }

          futures.each do |future|
            future.value
            if future.rejected?
              Rails.logger.error "[fetch_and_upsert] failed: #{future.reason.class}: #{future.reason.message}"
            end
          end

          GC.compact
        end

        Rails.logger.info "[fetch_and_upsert] done" if debug
      ensure
        pool.shutdown
        pool.wait_for_termination(60)
      end

      private

      def fetch_each_page(client, login, since, debug)
        Rails.logger.info "[fetch_each_page] resolving avatar_url for @#{login}" if debug
        actor_avatar_url = client.user(login).avatar_url
        Rails.logger.info "[fetch_each_page] avatar_url=#{actor_avatar_url}" if debug

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
