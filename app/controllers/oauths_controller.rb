class OauthsController < ApplicationController
  skip_before_filter :require_login

  def oauth
    login_at(params[:provider])
  end

  def callback
    provider = params[:provider]
    if @user = login_from(provider)
      redirect_to dashboard_path, notice: "Logged in from #{provider.titleize}!"
    else
      begin
        @user = create_from(provider)
        # TODO transaction
        auth = @user.authentication(provider)
        auth.token = token_from_credential(provider)
        auth.save!

        # NOTE: this is the place to add '@user.activate!' if you are using user_activation submodule

        reset_session # protect from session fixation attack
        auto_login(@user)
        redirect_to dashboard_path, notice: "Logged in from #{provider.titleize}!"
      rescue
        redirect_to root_path, alert: "Failed to login from #{provider.titleize}!"
      end
    end
  end

  private

  def token_from_credential(provider)
    Config.send(provider).access_token.token
  end
end
