class MyHotRepository < ApplicationMailer
  helper :application

  def notify(user)
    @user = user
    @star_events = @user.daily_star_events_by_followings

    mail to: user.email, subject: "Starred repositories by #{@user.username}'s followings"
  end
end
