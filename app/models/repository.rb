class Repository
  include Mongoid::Document

  class << self
    def fetch(reponame)
      repo = Octokit.repo(reponame)
      new(repo.to_hash)
    end
  end
end
