class DashboardController < ApplicationController
  before_filter :require_login, :assign_curent_user

  def show
    @watch_events = WatchEvent.by(@user.username).latest(7.days.ago).newly
    @watched_events = WatchEvent.owner(@user.username).latest(7.days.ago).newly
  end
end
