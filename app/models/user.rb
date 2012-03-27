class User < ActiveRecord::Base
  authenticates_with_sorcery!
  attr_accessible :name, :email, :subscribe, :authentications_attributes

  has_many :authentications, :dependent => :destroy
  accepts_nested_attributes_for :authentications

  before_save do
    if self.email_changed?
      self.activation_state = 'inactive'
    end
    if self.activation_state != 'active'
      self.activation_token ||= OpenSSL::Random.random_bytes(16).unpack("H*").first
    end
  end

  def authentication(provider)
    authentications.find_by_provider(provider)
  end

  def access_token
    @access_token ||= authentication(:github).token
  end

  def watch_events_by_followings
    following_names = followings.map do |following|
      following['login']
    end
    WatchEvent.all_by(following_names)
  end

  def followings
    page = 1
    followings = []
    loop do
      data = GithubEvents.followings(
        user: username,
        params: {
          access_token: access_token,
          page: page
        }
      )
      break if data.empty?
      followings += data
      page += 1
    end
    followings
  end
end
