class StarsController < ApplicationController
  rescue_from Octokit::NotFound do
    render status: :not_found, file: 'public/404.html', layout: false
  end

  def index
    @user = User.find_or_fetch_by_username(params[:username])
    StarEvent.fetch_and_upsert(client: Settings.github_client, logins: [@user.username], since: 7.days.ago)
    @star_events = StarEvent.by(@user.username).latest(7.days.ago).newly
  end
end
