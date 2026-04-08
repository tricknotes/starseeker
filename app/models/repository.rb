class Repository < ApplicationRecord
  Owner = Data.define(:login, :avatar_url)

  has_many :star_events, primary_key: :name, foreign_key: :repo_name

  def full_name
    name
  end

  def owner
    @owner ||= Owner.new(login: owner_login, avatar_url: owner_avatar_url)
  end

end
