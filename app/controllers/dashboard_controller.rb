class DashboardController < ApplicationController
  before_filter :require_login, :assing_curent_user

  def show
  end

  private

  def assing_curent_user
    @user = current_user
  end
end
