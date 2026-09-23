class MyHotRepositoryPreview < ActionMailer::Preview
  MISSING_USER = <<~MESSAGE.freeze
    No user in the database yet.  Sign in with GitHub once, then run
    `bin/rails star_events:fetch` to collect something to show here.
  MESSAGE

  def notify
    user = User.first
    raise MISSING_USER unless user

    # Roadie only inlines styles on delivery, and a preview never delivers.
    mail = MyHotRepository.notify(user).message
    Roadie::Rails::MailInliner.new(mail, Rails.application.config.roadie).execute
  end
end
