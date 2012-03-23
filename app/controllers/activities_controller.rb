class ActivitiesController < ApplicationController
  before_filter :require_login

  def watches
    @user = current_user
    @watch_events = @user.all_received_event.reverse
  end
end
