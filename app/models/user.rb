class User < ActiveRecord::Base
  authenticates_with_sorcery!
  attr_accessible :email, :password, :password_confirmation, :authentications_attributes

  has_many :authentications, :dependent => :destroy
  accepts_nested_attributes_for :authentications

  def authentication(provider)
    authentications.find_by_provider(provider)
  end

  def received_event(page = 1)
    GithubEvents.received_event(
      user: username,
      params: {
        access_token: authentication(:github).token,
        page: page
      }
    )
  end
end
