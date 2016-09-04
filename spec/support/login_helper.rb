module LoginHelper
  def stub_login!(user)
    authentication = user.authentications.first!

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      provider: 'github',
      uid:      authentication.uid,
      info: {
        nickname: user.username,
        email:    user.email,
        name:     user.name,
        image:    user.avatar_url
      },
      credentials: {
        token: authentication.token
      }
    )
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
