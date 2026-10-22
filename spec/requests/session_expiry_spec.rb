describe 'Session expiry' do
  include ActiveSupport::Testing::TimeHelpers
  include LoginHelper

  let(:user) { create(:user, :with_authentication) }

  before do
    stub_login!(user)
    get '/auth/github/callback'
  end

  it 'keeps the user logged in while they come back within 2 weeks' do
    travel 13.days
    get '/dashboard'
    travel 13.days
    get '/dashboard'

    expect(response).to have_http_status(:ok)
  end

  it 'logs out the user after 2 weeks of inactivity' do
    travel 15.days
    get '/dashboard'

    expect(response).to redirect_to(root_path)
  end
end
