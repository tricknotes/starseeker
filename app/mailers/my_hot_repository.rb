class MyHotRepository < ActionMailer::Base
  helper :application
  default from: "starseeker <#{Settings.mail.user_name}>"

  def notify(user)
    @user = user
    @star_events = @user.star_events_by_followings_with_me.latest(1.day.ago)
    mail(to: user.email, subject: "Watched repositories by #{@user.username}'s followings", css: :starseeker)
  end
end
