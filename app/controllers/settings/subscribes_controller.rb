class Settings::SubscribesController < ApplicationController
  before_filter :require_login, :assign_curent_user

  def show
  end

  def update
    @user.update_attributes!(params[:user])
    redirect_to dashboard_path, notice: 'Update receive setting.'
  end
end
