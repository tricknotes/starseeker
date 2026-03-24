class StarEvent < ApplicationRecord
  belongs_to :repository, primary_key: :name, foreign_key: :repo_name, optional: true

  scope :latest, ->(from) { where('starred_at >= ?', from) }
  scope :newly,  -> { order(starred_at: :desc) }
  scope :by,    ->(logins) { where(actor_login: logins) }
  scope :owner, ->(login) { where(repo_owner: login) }

  def self.fetch_and_upsert(client:, logins:, since:)
    logins.each do |login|
      star_events, repos = fetch_starred_since(client, login, since)
      next if star_events.empty?

      upsert_events(star_events)
      upsert_repositories(repos)
    end
  end

  def self.starred_ranking
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

  def self.each_with_repo
    includes(:repository).newly.each do |star_event|
      yield star_event, star_event.repository if star_event.repository
    end
  end

  def created_at
    starred_at
  end

  class << self
    private

    def fetch_starred_since(client, login, since)
      star_events = []
      repos = {}
      actor_avatar_url = client.user(login).avatar_url

      (1..).each do |page|
        starred = client.starred(
          login,
          sort: 'created',
          direction: 'desc',
          per_page: Octokit.per_page,
          page: page,
          headers: { accept: 'application/vnd.github.v3.star+json' }
        )
        break if starred.empty?

        starred.each do |item|
          starred_at = item.starred_at.is_a?(String) ? Time.parse(item.starred_at) : item.starred_at
          return [star_events, repos.values] if starred_at < since

          repo = item.repo
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

        break if starred.size < Octokit.per_page
      end

      [star_events, repos.values]
    end

    def upsert_events(star_events)
      StarEvent.upsert_all(star_events, unique_by: [:actor_login, :repo_name])
    end

    def upsert_repositories(repos)
      Repository.upsert_all(repos, unique_by: :name)
    end
  end
end
