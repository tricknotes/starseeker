class ApplicationController < ActionController::Base
  protect_from_forgery

  private

  def assing_curent_user
    @user = current_user
  end
end
