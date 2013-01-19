module LoginHelper
  def stub_login!(user)
    # Stub '#login_at' in '/oauth/:provider'
    override_once(OauthsController, :login_at) do |provider|
      redirect_to action: :callback, provider: provider
    end

    # Stub `#login_from` in '/oauth/callback'
    override_once(OauthsController, :login_from) do |provider|
      auto_login(user)
      after_login!(user)

      user
    end
  end

  def login_as(user)
    stub_login!(user)

    visit root_path
    within('nav') do
      click_link('Sign in with GitHub')
    end
  end

  def stub_signup!(user)
    # Stub '#login_at' in '/oauth/:provider'
    override_once(OauthsController, :login_at) do |provider|
      redirect_to action: :callback, provider: provider
    end

    # Stub `#login_from` in '/oauth/callback'
    override_once(OauthsController, :login_from) do |provider|
      nil
    end

    # Stub '#create_from' in '/oauth/:provider'
    override_once(OauthsController, :create_from) do |provider|
      user.save!
      user
    end

    # Stub '#token_from_credential' in '/oauth/:provider'
    override_once(OauthsController, :token_from_credential) do |provider|
      'OAUTH_TOKEN'
    end
  end

  def override_once(receiver, method_name, &block)
    original_method = receiver.instance_method(method_name)
    receiver.send(:define_method, method_name) do |*args|
      value = instance_exec(*args, &block)
      receiver.send(:define_method, method_name) do |*args|
        original_method.bind(self).call(*args)
      end
      value
    end
  end
end

RSpec.configuration.include LoginHelper, capybara_feature: true
