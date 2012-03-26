class ActivitiesController < ApplicationController
  before_filter :require_login

  def watches
    @user = current_user
    @watch_events = @user.watch_events_by_followings.with(@user.username).newly(1.day.ago)
  end
end
