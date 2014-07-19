class MyHotRepository < ActionMailer::Base
  include Roadie::Rails::Automatic

  helper :application
  default from: "starseeker <noreply@#{Settings.url_options[:host]}>"

  def notify(user)
    @user = user
    @star_events = @user.star_events_by_followings_with_me.latest(1.day.ago)

    mail to: user.email, subject: "Starred repositories by #{@user.username}'s followings"
  end
end
