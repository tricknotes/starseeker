module LoginHelper
  def stub_login!(user)
    # Stub '#login_at' in '/oauth/:provider'
    original_login_at = OauthsController.instance_method(:login_at)
    OauthsController.send(:define_method, :login_at) do |provider|

      redirect_to action: :callback, provider: provider

      # Remove stub
      OauthsController.send(:define_method, :login_at) do |provider|
        original_login_at.bind(self).call(provider)
      end
    end

    # Stub `#login_from` in '/oauth/callback'
    original_login_from = OauthsController.instance_method(:login_from)
    OauthsController.send(:define_method, :login_from) do |provider|
      auto_login(user)
      after_login!(user)

      # Remove stub
      OauthsController.send(:define_method, :login_from) do |provider|
        original_login_from.bind(self).call(provider)
      end

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
end

RSpec.configuration.include LoginHelper, capybara_feature: true
