class Settings::EmailsController < ApplicationController
  before_filter :require_login, :assign_curent_user

  def show
  end

  def update
    if @user.update_attributes(params[:user])
      message = @user.email_sendable? ? 'Send email to your address.' : 'Email info was updated'
      redirect_to dashboard_path, notice: message
    else
      render action: 'show'
    end
  end
end
