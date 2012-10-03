class Repository
  include Mongoid::Document

  index full_name: 1

  class << self
    def fetch(repo_name)
      repo = Octokit.repo(repo_name)
      new(repo.to_hash)
    rescue Octokit::NotFound
      nil
    end

    def fetch!(repo_name)
      repo = fetch(repo_name)
      return nil if repo.nil?
      existing_repo = self.where(full_name: repo.full_name).first
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
end
