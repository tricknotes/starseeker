class UsersController < ApplicationController
  def show
    @user = User.find_by_username(params[:id])
    @watch_events = WatchEvent.by(@user.username).newly
  end
end
