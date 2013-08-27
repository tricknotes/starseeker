class SessionsController < ApplicationController
  skip_before_filter :require_login, only: %w(activate)

  def create
    provider = auth_hash[:provider]
    uid      = auth_hash['uid']

    if @user = User.find_by_uid(uid)
      store_user @user

      redirect_to dashboard_path
    else
      begin
        @user = User.new(
          username:   auth_hash['info']['nickname'],
          email:      auth_hash['info']['email'],
          name:       auth_hash['info']['name'],
          avatar_url: auth_hash['info']['image']
        )
        @user.authentications.build(
          provider: provider,
          uid:      uid,
          token:    auth_hash['credentials']['token']
        )
        @user.save!

        if @user.email?
          UserMailer.activation_needed_email(@user).deliver
        end

        reset_session # protect from session fixation attack

        store_user @user
      rescue => e
        logger.error ["#{e.class} #{e.message}:", *e.backtrace.map {|m| '  '+m }].join("\n")
        redirect_to root_path, alert: "Failed to login from #{provider.titleize}. Wait a minute and try again."
        return
      end

      if @user.email?
        redirect_to dashboard_path
      else
        redirect_to settings_email_path, notice: "Please setup your email."
      end
    end
  end

  def activate
    @user = User.find_by_activation_token(params[:activation_token])

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

  private

  def auth_hash
    request.env['omniauth.auth']
  end
end
