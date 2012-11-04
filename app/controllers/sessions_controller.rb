class SessionsController < ApplicationController
  skip_before_filter :require_login, only: %w(activate)

  def activate
    @user = User.load_from_activation_token(params[:activation_token])
    if @user
      @user.activate!
      UserMailer.activation_success_email(@user).deliver

      redirect_to root_path, notice: 'You were successfully activated.'
    else
      not_authenticated
    end
  end

  def destroy
    logout
    redirect_to root_path, notice: 'Logged out.'
  end
end
