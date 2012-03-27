class DashboardController < ApplicationController
  before_filter :require_login, :assign_curent_user

  def show
  end
end
