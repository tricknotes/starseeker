class UserMailer < ActionMailer::Base
  default from: "starseeker <#{Settings.mail.user_name}>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activation_needed_email.subject
  #
  def activation_needed_email(user)
    @user = user
    @url  = activate_url(user.activation_token, host: Settings.host)
    mail to: user.email, subject: '[starseeker] Verify your email'
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activation_success_email.subject
  #
  def activation_success_email(user)
    @user = user
    @url  = auth_at_provider_url(provider: :github, host: Settings.host)
    mail to: user.email, subject: '[starseeker] Succeeded your email verification'
  end
end
