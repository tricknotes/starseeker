class Repository
  include Mongoid::Document

  class << self
    def fetch(reponame)
      repo = Octokit.repo(reponame)
      new(repo.to_hash)
    end

    def by_name(name)
      where(full_name: name).first
    end
  end
end
