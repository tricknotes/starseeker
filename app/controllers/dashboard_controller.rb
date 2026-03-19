class DashboardController < ApplicationController
  before_action :require_login, :assign_current_user

  def show
    StarEvent.fetch_and_upsert(client: @user.github_client, logins: [@user.username], since: 7.days.ago)
    @star_events = StarEvent.by(@user.username).latest(7.days.ago).newly
    @starred_events = StarEvent.owner(@user.username).latest(7.days.ago).newly
  end
end
