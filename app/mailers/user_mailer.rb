class UserMailer < ActionMailer::Base
  default from: "WatchMen <#{Settings.mail.sender}>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activation_needed_email.subject
  #
  def activation_needed_email(user)
    @user = user
    @url  = Settings.base_url + activate_path(user.activation_token)
    mail to: user.email
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activation_success_email.subject
  #
  def activation_success_email(user)
    @user = user
    @url  = Settings.base_url + auth_at_provider_path(provider: :github)
    mail to: user.email
  end
end
