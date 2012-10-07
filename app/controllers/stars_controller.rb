class StarsController < ApplicationController
  def index
    @user = User.find_by_username(params[:username])
    @watch_events = WatchEvent.by(@user.username).latest(7.days.ago).newly
  end
end
