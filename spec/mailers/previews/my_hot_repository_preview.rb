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

    # User#followings asks GitHub on every reload. The stored events came from
    # the followings anyway, so their actors stand in for the list.
    logins = StarEvent.latest(User::DAILY_TERM.ago).distinct.pluck(:actor_login)
    user.define_singleton_method(:followings) { logins }
    user
  end

  # Roadie only inlines styles on delivery, and a preview never delivers.
  def as_delivered(mail)
    Roadie::Rails::MailInliner.new(mail, Rails.application.config.roadie).execute
  end
end
