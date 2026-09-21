# Renders the daily "hot repositories" mail at
# /rails/mailers/my_hot_repository/notify so its layout can be checked in a
# browser without sending anything.
#
# The content comes from the development database.  Fill it with:
#
#   bin/rails star_events:fetch
class MyHotRepositoryPreview < ActionMailer::Preview
  MISSING_USER = <<~MESSAGE.freeze
    No user in the database yet.  Sign in with GitHub once, then run
    `bin/rails star_events:fetch` to collect something to show here.
  MESSAGE

  def notify
    as_delivered MyHotRepository.notify(reader).message
  end

  private

  def reader
    user = User.first
    raise MISSING_USER unless user

    # User#followings asks GitHub for the list, so leaving it alone would
    # spend an API call and several seconds on every reload of this page.
    # The stored events were collected from the people each user follows, so
    # the logins already in the table stand in for that list.
    logins = StarEvent.latest(User::DAILY_TERM.ago).distinct.pluck(:actor_login)
    user.define_singleton_method(:followings) { logins }
    user
  end

  # Roadie inlines the stylesheet when a mail is *delivered*, and a preview
  # never delivers.  Without this the page would show the markup from before
  # inlining, which is not what any recipient receives.
  def as_delivered(mail)
    Roadie::Rails::MailInliner.new(mail, Rails.application.config.roadie).execute
  end
end
