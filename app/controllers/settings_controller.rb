class SettingsController < ApplicationController
  before_filter :require_login, :assing_curent_user

  def email
  end

  def update_email
    if @user.update_attributes(params[:user])
      message = @user.email.present? ? 'Send email to your address.' : nil
      redirect_to dashboard_path, notice: message
    else
      render action: 'edit'
    end
  end

  private

  def assing_curent_user
    @user = current_user
  end
end
