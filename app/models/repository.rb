class Repository
  include Mongoid::Document

  index full_name: 1

  class << self
    def fetch(repo_name)
      repo = Settings.github_client.repo(repo_name)
      new(repo.to_hash)
    rescue Octokit::NotFound, Octokit::Forbidden
      nil
    end

    def fetch!(repo_name)
      repo = fetch(repo_name)
      return nil if repo.nil?

      existing_repo = self.by_name(repo.full_name)
      if existing_repo
        existing_repo.attributes = repo.attributes
        repo = existing_repo
      end
      repo.save!

      repo
    end

    def by_name(name)
      where(full_name: name).first
    end
  end

  # This method is exist for compatibility because github API doesn't support 'stars'.
  def stargazers_count
    self.watchers_count
  end

  def created_at
    self['created_at'].to_datetime
  end
end
