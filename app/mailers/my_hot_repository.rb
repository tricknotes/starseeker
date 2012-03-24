class MyHotRepository < ActionMailer::Base
  helper :application
  default from: Settings.mailer.from

  def notify(user)
    @user = user
    @watch_events = @user.watch_events_by_followings.where(created_at: {'$gte' => 1.day.ago.to_s})
    mail(to: user.email, subject: "Watched repositories by #{@user.username}'s followings")
  end
end
