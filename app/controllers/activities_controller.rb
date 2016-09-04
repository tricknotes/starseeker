class ActivitiesController < ApplicationController
  before_action :require_login, only: %w(starring)
  before_action :login_from_feed_token, only: %w(feed)

  def starring
    @user = current_user
    @star_events = @user.star_events_by_followings_with_me.latest(1.day.ago)
  end

  def feed
    @star_events = @user.star_events_by_followings_with_me.latest(1.day.ago)
    @latest_event = @star_events.first

    respond_to do |format|
      format.atom
    end
  end

  private

  def login_from_feed_token
    head :unauthorized if params[:token].blank?

    @user = User.where(username: params[:username], feed_token: params[:token]).first

    head :unauthorized unless @user
  end
end
