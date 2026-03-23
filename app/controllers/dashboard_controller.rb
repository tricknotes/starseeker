class DashboardController < ApplicationController
  before_action :require_login, :assign_current_user

  def show
    @star_events = StarEvent.by(@user.username).latest(7.days.ago).newly
    @starred_events = StarEvent.owner(@user.username).latest(7.days.ago).newly
  end
end
