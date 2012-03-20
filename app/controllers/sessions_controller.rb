class SessionsController < ApplicationController
  def create
    @user = User.find_or_create_from_auth_hash(request.env['omniauth.auth'])
    self.current_user = @user
    redirect_to root_path, notice: I18n.t('devise.sessions.signed_in')
  end

  def destroy
    self.current_user = nil
    redirect_to root_path, notice: I18n.t('devise.sessions.signed_out')
  end

  def failure
    redirect_to root_path, error: 'Signed in failure.'
  end
end
