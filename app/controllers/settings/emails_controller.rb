class Settings::EmailsController < ApplicationController
  before_action :require_login, :assign_current_user

  def show
  end

  def update
    before_email = @user.email

    if @user.update(setting_email_params)
      if @user.email_sendable? && before_email != @user.email
        send_actiavtion_mail(@user)

        message = 'Send email to your address.'
      else
        message = 'Email info was updated'
      end

      redirect_to dashboard_path, notice: message
    else
      render action: 'show'
    end
  end

  def send_confirmation
    send_actiavtion_mail(@user)
    redirect_to dashboard_path, notice: 'Confirmation mail has been sent to your mailbox.'
  end

  private

  def setting_email_params
    params.require(:user).permit(:email, :subscribe)
  end

  def send_actiavtion_mail(user)
    UserMailer.activation_needed_email(user).deliver_now
  end
end
