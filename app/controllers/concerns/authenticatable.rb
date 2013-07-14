module Authenticatable
  extend ActiveSupport::Concern

  included do
    helper_method :current_user
    helper_method :logged_in?
  end

  def require_login
    redirect_to root_path unless logged_in?
  end

  def store_user(user)
    session[:user_id] = user.id
  end

  def current_user
    return @current_uer if defined? @current_uer

    @current_user = User.find_by_id(session[:user_id])
  end

  def logged_in?
    !!current_user
  end
end
