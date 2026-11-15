describe 'Sessions' do
  include LoginHelper

  describe 'GET /auth/github/callback' do
    let(:user) { create(:user, :with_authentication) }

    before do
      stub_login!(user)
    end

    it 'starts a new session when an existing user logs in' do
      get '/auth/github/callback'
      session_id_before_login = session.id.public_id

      get '/auth/github/callback'

      expect(session[:user_id]).to eq(user.id)
      expect(session.id.public_id).not_to eq(session_id_before_login)
    end

    it 'takes the new token when a user whose token was revoked logs in again' do
      user.revoke_token!
      OmniAuth.config.mock_auth[:github].credentials.token = 'NEW_TOKEN'

      get '/auth/github/callback'

      user.reload
      expect(user).not_to be_token_revoked
      expect(user.access_token).to eq('NEW_TOKEN')
    end
  end
end
