class ActivitiesController < ApplicationController
  before_filter :require_login

  def starring
    @user = current_user
    @star_events = @user.star_events_by_followings_with_me.latest(1.day.ago)
  end
end
