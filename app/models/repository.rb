class Repository
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  index full_name: 1

  class << self
    def fetch(repo_name)
      repo = Settings.github_client.repo(repo_name)
      new(to_hash_deeply(repo))
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

    private

    def to_hash_deeply(hash_like)
      return hash_like unless hash_like.respond_to?(:to_hash, true)

      hash_like.to_hash.with_indifferent_access.inject({}) {|hash, (key, value)|
        hash[key] = to_hash_deeply(value)
        hash
      }
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
