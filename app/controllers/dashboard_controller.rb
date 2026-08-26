class DashboardController < ApplicationController
  before_action :require_login, :assign_current_user

  def show
    @star_events = @user.recent_star_events
    @starred_events = @user.recent_star_events_on_my_repositories
  end
end
