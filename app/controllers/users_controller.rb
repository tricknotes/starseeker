class UsersController < ApplicationController
  def show
    @user = User.find_by_username(params[:id])
    @watch_events = WatchEvent.where('actor.login' => @user.username).order_by([:created_at, :desc])
  end
end
