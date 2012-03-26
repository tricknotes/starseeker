class UsersController < ApplicationController
  def show
    @user = User.find_by_username(params[:id])
    @watch_events = WatchEvent.where('actor.login' => @user.username)
  end
end
