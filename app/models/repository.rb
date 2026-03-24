class Repository < ApplicationRecord
  Owner = Data.define(:login, :avatar_url)

  has_many :star_events, primary_key: :name, foreign_key: :repo_name

  def self.by_name(name)
    find_by(name: name)
  end

  def full_name
    name
  end

  def owner
    @owner ||= Owner.new(login: owner_login, avatar_url: owner_avatar_url)
  end

  # Compatibility: GitHub API uses watchers_count for stargazers_count
  def watchers_count
    stargazers_count
  end
end
