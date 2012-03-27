class DashboardController < ApplicationController
  before_filter :require_login, :assing_curent_user

  def show
  end
end
