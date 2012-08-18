class Repository
  include Mongoid::Document

  class << self
    def fetch(login, name)
      repo = Octokit.repo(username: login, repo: name)
      new(repo.to_hash)
    end
  end
end
