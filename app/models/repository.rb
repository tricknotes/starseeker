class Repository < ApplicationRecord
  has_many :star_events, primary_key: :name, foreign_key: :repo_name

  def self.by_name(name)
    find_by(name: name)
  end

  def full_name
    name
  end

  def owner
    @owner ||= OpenStruct.new(login: owner_login, avatar_url: owner_avatar_url)
  end

  # Compatibility: GitHub API uses watchers_count for stargazers_count
  alias_method :watchers_count, :stargazers_count
end
