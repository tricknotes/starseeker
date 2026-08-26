class MyHotRepository < ActionMailer::Base
  include Roadie::Rails::Automatic

  helper :application
  default from: "starseeker <noreply@#{Settings.url_options[:host]}>"

  def notify(user)
    @user = user
    @star_events = @user.daily_star_events_by_followings

    mail to: user.email, subject: "Starred repositories by #{@user.username}'s followings"
  end
end
