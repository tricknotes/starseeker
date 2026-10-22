describe 'Feed logging' do
  let(:user) { create(:user, :with_authentication) }

  before do
    allow_any_instance_of(User).to receive(:followings).and_return([])
    allow(Rails.logger).to receive(:info).and_call_original
  end

  it 'logs the User-Agent on a single line' do
    get feed_path(username: user.username, format: 'atom', token: user.feed_token),
        headers: {'User-Agent' => "Reader\n[TRACK] forged line"}

    expect(Rails.logger).to have_received(:info).with(%([TRACK][UA - activities#feed] User#id=#{user.id} - "Reader\\n[TRACK] forged line"))
  end
end
