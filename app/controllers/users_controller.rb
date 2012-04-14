class UsersController < ApplicationController
  def show
    @user = User.find_by_username(params[:id])
    @watch_events = WatchEvent.by(@user.username).latest(7.days.ago).newly
  end
end
