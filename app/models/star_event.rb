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
    class_methods do
      def fetch_and_upsert(client:, logins:, since:, debug: false)
        Rails.logger.info "[fetch_and_upsert] start: #{logins.size} logins, since=#{since}" if debug

        logins.each_with_index do |login, i|
          Rails.logger.info "[fetch_and_upsert] (#{i + 1}/#{logins.size}) fetching @#{login}" if debug
          started_at = Time.current

          begin
            star_events, repos = fetch_starred_since(client, login, since, debug)
          rescue => e
            Rails.logger.error "[fetch_and_upsert] failed to fetch @#{login}: #{e.class}: #{e.message}"
            next
          end

          elapsed = (Time.current - started_at).round(2)
          Rails.logger.info "[fetch_and_upsert] @#{login}: #{star_events.size} events, #{repos.size} repos (#{elapsed}s)" if debug

          next if star_events.empty?

          upsert_events(star_events, debug)
          upsert_repositories(repos, debug)
        end

        Rails.logger.info "[fetch_and_upsert] done" if debug
      end

      private

      def fetch_starred_since(client, login, since, debug)
        star_events = []
        repos = {}

        Rails.logger.info "[fetch_starred_since] resolving avatar_url for @#{login}" if debug
        actor_avatar_url = client.user(login).avatar_url
        Rails.logger.info "[fetch_starred_since] avatar_url=#{actor_avatar_url}" if debug

        (1..).each do |page|
          Rails.logger.info "[fetch_starred_since] @#{login} fetching page=#{page}" if debug

          starred = client.starred(
            login,
            sort: 'created',
            direction: 'desc',
            per_page: Octokit.per_page,
            page: page,
            headers: { accept: 'application/vnd.github.v3.star+json' }
          )

          Rails.logger.info "[fetch_starred_since] @#{login} page=#{page}: #{starred.size} items" if debug
          break if starred.empty?

          starred.each do |item|
            starred_at = item.starred_at.is_a?(String) ? Time.parse(item.starred_at) : item.starred_at

            if starred_at < since
              Rails.logger.info "[fetch_starred_since] @#{login} reached since (#{item.repo.full_name} starred_at=#{starred_at}), stopping" if debug
              return [star_events, repos.values]
            end

            repo = item.repo
            Rails.logger.info "[fetch_starred_since] @#{login} +#{repo.full_name} (starred_at=#{starred_at})" if debug

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

          if starred.size < Octokit.per_page
            Rails.logger.info "[fetch_starred_since] @#{login} last page reached (#{starred.size} < #{Octokit.per_page})" if debug
            break
          end
        end

        Rails.logger.info "[fetch_starred_since] @#{login} total: #{star_events.size} events collected" if debug
        [star_events, repos.values]
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
