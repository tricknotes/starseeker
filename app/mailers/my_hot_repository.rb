class MyHotRepository < ActionMailer::Base
  helper :application
  default from: "Watchmen <#{Settings.mail.user_name}>"

  def notify(user)
    @user = user
    @watch_events = @user.watch_events_by_followings_with_me.latest(1.day.ago)
    mail(to: user.email, subject: "Watched repositories by #{@user.username}'s followings")
  end
end
