class Authentication < ActiveRecord::Base
  # TODO I wish to eliminate `attr_accessible`!
  # patch for sorcery with rails4.
  attr_accessible :user_id, :provider, :uid
  belongs_to :user
end
