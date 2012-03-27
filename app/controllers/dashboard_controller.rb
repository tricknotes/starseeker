class DashboardController < ApplicationController
  before_filter :require_login, :assign_curent_user

  def show
    @watch_event = WatchEvent.by(@user.username).newly
    @watched_event = WatchEvent.owner(@user.username).newly
  end
end
