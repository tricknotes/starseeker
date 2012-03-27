class MyHotRepository < ActionMailer::Base
  helper :application
  default from: "WatchMen <#{Settings.mail.sender}>"

  def notify(user)
    @user = user
    @watch_events = @user.watch_events_by_followings.latest(1.day.ago)
    mail(to: user.email, subject: "Watched repositories by #{@user.username}'s followings")
  end
end
