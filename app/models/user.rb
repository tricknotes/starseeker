class User < ApplicationRecord
  MAX_FOLLOWER_PAGE_COUNT = 50

  # How far back the "daily" and "recent" listings look.
  DAILY_TERM  = 1.day
  RECENT_TERM = 7.days

  # Repositories asked about per GraphQL query in #starred_repository_names.
  # GitHub charges one point per repository node, so this stays far from the
  # per-query limit.
  STARRED_QUERY_BATCH_SIZE = 100

  scope :email_sendables, -> { where(subscribe: true, activation_state: 'active') }
  scope :newly, -> { order(created_at: :desc) }
  scope :randomly, -> { order(Arel.sql('RANDOM()')) }

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
      find_by(username: username) || User.new {|user|
        github_user = Settings.github_client.user(username)
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

  # GitHub's own naming for a username, so that a User duck-types with
  # Repository::Owner wherever a GitHub account is rendered.
  # (Not `alias_method`: `username` is a lazily generated attribute method and
  # is not defined yet while this class body is evaluated.)
  def login
    username
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
    StarEvent.by(followings + [username])
  end

  # Repositories starred by the people this user follows (and by the user).
  def daily_star_events_by_followings
    star_events_by_followings_with_me.latest(DAILY_TERM.ago)
  end

  # Repositories this user starred recently.
  def recent_star_events
    StarEvent.by(username).latest(RECENT_TERM.ago).newly
  end

  # This user's own repositories that were starred recently by someone.
  def recent_star_events_on_my_repositories
    StarEvent.owner(username).latest(RECENT_TERM.ago).newly
  end

  # Names of the given repositories that this user has starred, as a Set.
  #
  # GitHub is asked (viewerHasStarred) so that a star put on a repository long
  # ago is found too; the star events kept locally only go back a few days.
  # When GitHub cannot be asked (no token, a revoked token, a network error)
  # those local events are used instead, so the answer degrades to "starred
  # recently" rather than breaking the page.
  def starred_repository_names(repo_names)
    repo_names = repo_names.uniq
    return Set.new if repo_names.empty?

    return locally_starred_repository_names(repo_names) unless access_token

    starred = Set.new

    GithubGraphql.connect do |http|
      repo_names.each_slice(STARRED_QUERY_BATCH_SIZE) do |batch|
        result = GithubGraphql.execute(http, access_token, starred_query_for(batch))

        # A bad token gives a body without "data" at all, unlike a repository
        # that no longer exists, which only nulls its own alias.
        raise GithubGraphql::Error, result['message'] unless result.key?('data')

        batch.each_with_index do |repo_name, idx|
          starred << repo_name if result.dig('data', "r#{idx}", 'viewerHasStarred')
        end
      end
    end

    starred
  rescue GithubGraphql::Error, *GithubGraphql::CONNECTION_ERRORS => e
    Rails.logger.warn "[starred_repository_names] @#{username}: #{e.class}: #{e.message} - falling back to local star events"
    locally_starred_repository_names(repo_names)
  end

  def followings
    return @followings if @followings

    @followings = []

    (1..MAX_FOLLOWER_PAGE_COUNT).each do |page|
      followings_in_one_page = github_client.following(username, page: page)
                                            .filter_map { |f| f['login'] if f['type'] == 'User' }
      @followings += followings_in_one_page
      break if Octokit.per_page > followings_in_one_page.count
    end

    @followings
  end

  def github_client
    @github_client ||= Octokit::Client.new(login: username, access_token: access_token)
  end

  private

  def starred_query_for(repo_names)
    fields = repo_names.each_with_index.map {|repo_name, idx|
      owner, name = repo_name.split('/', 2)
      "r#{idx}: repository(owner: #{owner.to_json}, name: #{name.to_json}) { viewerHasStarred }"
    }

    "query {\n#{fields.join("\n")}\n}"
  end

  def locally_starred_repository_names(repo_names)
    StarEvent.by(username).where(repo_name: repo_names).pluck(:repo_name).to_set
  end

  def generate_token
    OpenSSL::Random.random_bytes(16).unpack("H*").first
  end
end
