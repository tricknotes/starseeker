class UserObserver < ActiveRecord::Observer
  def after_save(user)
    if user.email.present? && user.email_changed?
      send_confirmation_mail(user)
    end
  end

  private
  def send_confirmation_mail(user)
    UserMailer.activation_needed_email(user)
  end
end
