class StarsController < ApplicationController
  rescue_from Octokit::NotFound do
    render status: 404, file: 'public/404.html', layout: false
  end

  def index
    @user = User.find_or_fetch_by_username(params[:username])
    @watch_events = WatchEvent.by(@user.username).latest(7.days.ago).newly
  end
end
