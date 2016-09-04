class User < ActiveRecord::Base
  attr_accessor :github_client

  MAX_FOLLOWER_PAGE_COUNT = 50

  scope :email_sendables, -> { where(subscribe: true, activation_state: 'active') }
  scope :newly, -> { order('created_at DESC') }

  has_many :authentications, dependent: :destroy
  accepts_nested_attributes_for :authentications

  before_save do
    if self.email_changed?
      self.activation_state = nil
    end
    unless self.active?
      self.activation_token ||= generate_token
    end

    self.feed_token ||= generate_token
  end

  class << self
    def find_or_fetch_by_username(username)
      self.find_by_username(username) || User.new {|user|
        user.github_client = Settings.github_client
        github_user = user.github_client.user(username)
        user.username = github_user.login
        user.avatar_url = github_user.avatar_url
      }
    end

    def find_by_uid(uid)
      auth = Authentication.find_by(uid: uid, provider: :github)

      return unless auth

      auth.user
    end
  end

  def access_token
    @access_token ||= authentications.find_by(provider: :github)&.token
  end

  def email_sendable?
    email.present? && subscribe
  end

  def active?
    'active' == activation_state
  end

  def activate!
    update!(
      activation_token: nil,
      activation_state: 'active'
    )
  end

  def star_events_by_followings_with_me
    following_names = followings.map do |following|
      following['login']
    end

    StarEvent.all_by(following_names + [username])
  end

  def followings
    return @followings if @followings

    @followings = []

    (1..MAX_FOLLOWER_PAGE_COUNT).each do |page|
      followings_in_one_page = github_client.following(username, page: page)
      @followings += followings_in_one_page
      break if Octokit.per_page > followings_in_one_page.count
    end

    @followings
  end

  def github_client
    @github_client ||= Octokit::Client.new(login: username, access_token: access_token)
  end

  private

  def generate_token
    OpenSSL::Random.random_bytes(16).unpack("H*").first
  end
end
