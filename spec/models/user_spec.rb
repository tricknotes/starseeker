describe User do
  describe 'default attributes' do
    its(:activation_state) { is_expected.to be_nil }
    its(:subscribe) { is_expected.to be_truthy }
  end

  describe '#access_token' do
    context 'when github authentication is exist' do
      subject do
        create(:user, :with_authentication)
      end

      its(:access_token) { is_expected.to eq('GITHUB_TOKEN') }
    end

    context 'when github authentication is not exist' do
      its(:access_token) { is_expected.to be_nil }
    end
  end

  describe '#feed_token' do
    subject do
      create(:user)
    end

    its(:feed_token) { is_expected.to match(/\A.{32}\z/) }
    its(:feed_token) { is_expected.not_to be_blank }
  end

  describe '#email_sendable?' do
    subject { build(:user) }

    context 'when email is not exist' do
      before { subject.email = nil}
      its(:email_sendable?) { is_expected.to be_falsey }
    end

    context 'when subscribe is false' do
      before { subject.subscribe = false }
      its(:email_sendable?) { is_expected.to be_falsey }
    end

    context 'when email is exist and subscribe is true' do
      its(:email_sendable?) { is_expected.to be_truthy }
    end
  end

  describe '#active?' do
    subject { build(:user) }

    context 'when activation_state is "active"' do
      its(:active?) { is_expected.to be_truthy }
    end

    context 'when activation_state is `nil`' do
      before { subject.activation_state = nil }
      its(:active?) { is_expected.to be_falsey }
    end
  end

  describe '#followings' do
    subject(:user) { build(:user, username: 'alice') }

    let(:client) { instance_double(Octokit::Client) }

    before do
      allow(user).to receive(:github_client).and_return(client)
    end

    def following_entry(login:, type: 'User')
      { 'login' => login, 'type' => type }
    end

    context 'when followings include both users and organizations' do
      before do
        allow(client).to receive(:following).and_return([
          following_entry(login: 'bob',       type: 'User'),
          following_entry(login: 'acme-corp', type: 'Organization'),
          following_entry(login: 'carol',     type: 'User'),
        ])
      end

      it 'returns only user logins' do
        expect(user.followings).to contain_exactly('bob', 'carol')
      end

      it 'excludes organizations' do
        expect(user.followings).not_to include('acme-corp')
      end
    end

    context 'when all followings are organizations' do
      before do
        allow(client).to receive(:following).and_return([
          following_entry(login: 'acme-corp', type: 'Organization'),
        ])
      end

      it 'returns an empty array' do
        expect(user.followings).to be_empty
      end
    end

    context 'when there are no followings' do
      before do
        allow(client).to receive(:following).and_return([])
      end

      it 'returns an empty array' do
        expect(user.followings).to be_empty
      end
    end
  end
end
