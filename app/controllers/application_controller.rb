class ApplicationController < ActionController::Base
  include Authenticatable

  protect_from_forgery

  private

  def assign_curent_user
    @user = current_user
  end
end
