class ActivitiesController < ApplicationController
  before_filter :require_login

  def watches
    @user = current_user
    all_received_event = @user.all_received_event
    @watch_events = all_received_event.select {|e| e['type'] == 'WatchEvent' }
  end
end
