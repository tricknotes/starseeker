class Settings::EmailsController < ApplicationController
  before_action :require_login, :assign_current_user

  # Both actions can mail an address that has not been verified yet, so
  # without a limit they could be used to flood someone else's inbox.
  rate_limit to: 5, within: 1.hour, by: -> { @user.id }, only: %i(update send_confirmation),
             with: -> { redirect_to dashboard_path, alert: 'Too many requests. Please try again later.' }

  def show
  end

  def update
    before_email = @user.email

    if @user.update(setting_email_params)
      if @user.email_sendable? && before_email != @user.email
        send_activation_mail(@user)

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
    send_activation_mail(@user)
    redirect_to dashboard_path, notice: 'Confirmation mail has been sent to your mailbox.'
  end

  private

  def setting_email_params
    params.require(:user).permit(:email, :subscribe)
  end

  def send_activation_mail(user)
    UserMailer.activation_needed_email(user).deliver_now
  end
end
