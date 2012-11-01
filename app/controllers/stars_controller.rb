class StarsController < ApplicationController
  rescue_from Octokit::NotFound do
    render status: :not_found, file: 'public/404.html', layout: false
  end

  def index
    @user = User.find_or_fetch_by_username(params[:username])
    @star_events = StarEvent.by(@user.username).latest(7.days.ago).newly
  end
end
