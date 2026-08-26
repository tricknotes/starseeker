class StarsController < ApplicationController
  rescue_from Octokit::NotFound do
    # `render file:` resolves its argument with File.exist?, so a relative path
    # only works while the working directory happens to be the app root.
    render status: :not_found, file: Rails.public_path.join('404.html').to_s, layout: false
  end

  def index
    @user = User.find_or_fetch_by_username(params[:username])
    @star_events = @user.recent_star_events
  end
end
