class Repository
  include Mongoid::Document

  class << self
    def fetch(reponame)
      repo = Octokit.repo(reponame)
      new(repo.to_hash)
    rescue Octokit::NotFound
      nil
    end

    def fetch!(reponame)
      repo = fetch(reponame)
      return nil if repo.nil?
      repo.save!
      repo
    end

    def by_name(name)
      where(full_name: name).first
    end
  end
end
