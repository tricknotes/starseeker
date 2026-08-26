class ActivitiesController < ApplicationController
  before_action :require_login, only: %i(starring)
  before_action :login_from_feed_token, only: %i(feed)

  def starring
    @user = current_user
    @star_events = @user.daily_star_events_by_followings
  end

  def feed
    @star_events = @user.daily_star_events_by_followings
    @latest_event = @star_events.newly.first

    respond_to do |format|
      format.atom { logging_ua }
    end
  end

  private

  def login_from_feed_token
    return head :unauthorized if params[:token].blank?

    @user = User.find_by(username: params[:username], feed_token: params[:token])

    head :unauthorized unless @user
  end

  def logging_ua
    Rails.logger.info "[TRACK][UA - #{params[:controller]}##{params[:action]}] User#id=#{@user.id} - \"#{request.user_agent}\""
  end
end
