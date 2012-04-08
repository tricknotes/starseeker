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
        User.transaction do
          @user = create_from(provider)
          auth = @user.authentication(provider)
          auth.token = token_from_credential(provider)
          auth.save!
        end

        # NOTE: this is the place to add '@user.activate!' if you are using user_activation submodule

        reset_session # protect from session fixation attack
        auto_login(@user)
        if @user.email.present?
          redirect_to dashboard_path, notice: "Logged in from #{provider.titleize}!"
        else
          redirect_to settings_email_path, notice: "Please regist your email."
        end
      rescue => e
        logger.error ["#{e.class} #{e.message}:", *e.backtrace.map {|m| '  '+m }].join("\n")
        redirect_to root_path, alert: "Failed to login from #{provider.titleize}!"
      end
    end
  end

  private

  def token_from_credential(provider)
    Sorcery::Controller::Config.send(provider).access_token.token
  end
end
