describe User do
  describe 'default attributes' do
    it { expect(subject.activation_state).to be_nil }
    it { expect(subject.subscribe).to be_truthy }
  end

  describe '#access_token' do
    context 'when github authentication is exist' do
      subject do
        create(:user, :with_authentication)
      end

      it { expect(subject.access_token).to eq('GITHUB_TOKEN') }
    end

    context 'when github authentication is not exist' do
      it { expect(subject.access_token).to be_nil }
    end
  end

  describe '#login' do
    subject { build(:user, username: 'alice') }

    it { expect(subject.login).to eq('alice') }
  end

  describe '#feed_token' do
    subject do
      create(:user)
    end

    it { expect(subject.feed_token).to match(/\A.{32}\z/) }
    it { expect(subject.feed_token).not_to be_blank }
  end

  describe '#activation_token' do
    subject { create(:user, email: 'first@example.com') }

    it 'is not carried over to another email while the first one is unverified' do
      first_token = subject.activation_token

      subject.update!(email: 'second@example.com')

      expect(subject.activation_token).to be_present
      expect(subject.activation_token).not_to eq(first_token)
    end
  end

  describe '#email_sendable?' do
    subject { build(:user) }

    context 'when email is not exist' do
      before { subject.email = nil}
      it { expect(subject.email_sendable?).to be_falsey }
    end

    context 'when subscribe is false' do
      before { subject.subscribe = false }
      it { expect(subject.email_sendable?).to be_falsey }
    end

    context 'when email is exist and subscribe is true' do
      it { expect(subject.email_sendable?).to be_truthy }
    end
  end

  describe '#active?' do
    subject { build(:user) }

    context 'when activation_state is "active"' do
      it { expect(subject.active?).to be_truthy }
    end

    context 'when activation_state is `nil`' do
      before { subject.activation_state = nil }
      it { expect(subject.active?).to be_falsey }
    end
  end

  describe '.email_sendables' do
    let!(:user) { create(:user).tap(&:activate!) }

    it { expect(User.email_sendables).to eq([user]) }

    context 'when the token is revoked' do
      before { user.revoke_token! }

      it { expect(User.email_sendables).to be_empty }
    end
  end

  describe '#revoke_token!' do
    include ActiveSupport::Testing::TimeHelpers

    let(:user) { create(:user) }

    it 'keeps the time it was first revoked' do
      travel_to(Time.zone.local(2026, 11, 1)) { user.revoke_token! }
      travel_to(Time.zone.local(2026, 11, 2)) { user.revoke_token! }

      expect(user.reload.token_revoked_at).to eq(Time.zone.local(2026, 11, 1))
    end
  end

  describe '#renew_token!' do
    let(:user) { create(:user, :with_authentication) }

    before do
      user.revoke_token!
      user.access_token

      user.renew_token!('NEW_TOKEN')
    end

    it { expect(user.reload).not_to be_token_revoked }
    it { expect(user.access_token).to eq('NEW_TOKEN') }
  end

  describe '#starred_repository_names' do
    let(:http) { instance_double(Net::HTTP) }
    let(:requests) { [] }

    def stub_graphql(*bodies)
      allow(Net::HTTP).to receive(:start).and_yield(http)
      allow(http).to receive(:request) {|request|
        requests << request
        instance_double(Net::HTTPResponse, body: bodies.shift.to_json)
      }
    end

    def repository_result(starred)
      starred.nil? ? nil : { 'viewerHasStarred' => starred }
    end

    context 'when the user has a GitHub token' do
      subject(:user) { create(:user, :with_authentication, username: 'alice') }

      it 'asks GitHub which of the repositories the user has starred' do
        stub_graphql(
          'data' => {
            'r0' => repository_result(true),
            'r1' => repository_result(false),
            'r2' => repository_result(true),
          }
        )

        expect(user.starred_repository_names(%w(a/one b/two c/three)))
          .to eq(Set.new(%w(a/one c/three)))

        expect(requests.size).to eq(1)
        expect(requests.first['Authorization']).to eq('bearer GITHUB_TOKEN')
        expect(JSON.parse(requests.first.body)['query'])
          .to include('r0: repository(owner: "a", name: "one") { viewerHasStarred }')
          .and include('r2: repository(owner: "c", name: "three") { viewerHasStarred }')
      end

      it 'treats a repository GitHub no longer knows as not starred' do
        stub_graphql(
          'data'   => { 'r0' => nil, 'r1' => repository_result(true) },
          'errors' => [{ 'message' => "Could not resolve to a Repository with the name 'gone/repo'." }]
        )

        expect(user.starred_repository_names(%w(gone/repo b/two))).to eq(Set.new(%w(b/two)))
      end

      it 'asks about the repositories in batches' do
        stub_const('User::STARRED_QUERY_BATCH_SIZE', 2)
        stub_graphql(
          { 'data' => { 'r0' => repository_result(true),  'r1' => repository_result(false) } },
          { 'data' => { 'r0' => repository_result(false), 'r1' => repository_result(true) } },
          { 'data' => { 'r0' => repository_result(true) } },
        )

        expect(user.starred_repository_names(%w(a/1 a/2 a/3 a/4 a/5))).to eq(Set.new(%w(a/1 a/4 a/5)))
        expect(requests.size).to eq(3)
      end

      it 'asks about each repository once' do
        stub_graphql('data' => { 'r0' => repository_result(true) })

        expect(user.starred_repository_names(%w(a/one a/one))).to eq(Set.new(%w(a/one)))
        expect(JSON.parse(requests.first.body)['query'].scan('repository(').size).to eq(1)
      end

      it 'does not ask GitHub when there is nothing to ask about' do
        expect(Net::HTTP).not_to receive(:start)

        expect(user.starred_repository_names([])).to eq(Set.new)
      end

      context 'when GitHub cannot be asked' do
        before do
          stub_star_event! actor: {login: 'alice'}, repo: {name: 'a/one'}
        end

        it 'falls back to the local star events when the token is rejected' do
          stub_graphql('message' => 'Bad credentials')

          expect(user.starred_repository_names(%w(a/one b/two))).to eq(Set.new(%w(a/one)))
        end

        it 'falls back to the local star events when the connection fails' do
          allow(Net::HTTP).to receive(:start).and_raise(Net::OpenTimeout)

          expect(user.starred_repository_names(%w(a/one b/two))).to eq(Set.new(%w(a/one)))
        end

        it 'gives up after a few seconds rather than holding the page' do
          allow(Net::HTTP).to receive(:start)
            .with('api.github.com', 443, hash_including(open_timeout: 3, read_timeout: 5))
            .and_yield(http)
          allow(http).to receive(:request).and_raise(Net::ReadTimeout)

          expect(user.starred_repository_names(%w(a/one b/two))).to eq(Set.new(%w(a/one)))
        end
      end
    end

    context 'when the GitHub token is known to be revoked' do
      subject(:user) { create(:user, :with_authentication, username: 'alice').tap(&:revoke_token!) }

      before do
        stub_star_event! actor: {login: 'alice'}, repo: {name: 'a/one'}
      end

      it 'answers from the local star events without asking GitHub' do
        expect(Net::HTTP).not_to receive(:start)

        expect(user.starred_repository_names(%w(a/one b/two))).to eq(Set.new(%w(a/one)))
      end
    end

    context 'when the user has no GitHub token' do
      subject(:user) { create(:user, username: 'alice') }

      before do
        stub_star_event! actor: {login: 'alice'}, repo: {name: 'a/one'}
        stub_star_event! actor: {login: 'bob'},   repo: {name: 'b/two'}
      end

      it 'answers from the local star events without asking GitHub' do
        expect(Net::HTTP).not_to receive(:start)

        expect(user.starred_repository_names(%w(a/one b/two c/three))).to eq(Set.new(%w(a/one)))
      end
    end
  end

  describe '#followings' do
    subject(:user) { build(:user, username: 'alice') }

    let(:client) { instance_double(Octokit::Client) }

    before do
      allow(user).to receive(:github_client).and_return(client)
      allow(client).to receive(:last_response).and_return(response_with_last_page(nil))
    end

    def following_entry(login:, type: 'User')
      { 'login' => login, 'type' => type }
    end

    def response_with_last_page(page)
      rels = page ? { last: double(href: "https://api.github.com/user/1/following?per_page=100&page=#{page}") } : {}

      instance_double(Sawyer::Response, rels: rels)
    end

    context 'when followings span several pages' do
      before do
        allow(client).to receive(:last_response).and_return(response_with_last_page(3))
        allow(client).to receive(:following) {|_, page:| [following_entry(login: "user#{page}")] }
      end

      it 'fetches every page and keeps them in order' do
        expect(user.followings).to eq(%w(user1 user2 user3))
        expect(client).to have_received(:following).with('alice', page: 1).once
        expect(client).to have_received(:following).with('alice', page: 2).once
        expect(client).to have_received(:following).with('alice', page: 3).once
      end

      it 'fetches the pages after the first one concurrently' do
        started = Queue.new
        release = Queue.new
        allow(client).to receive(:following) {|_, page:|
          if page > 1
            started << page
            release.pop
          end

          [following_entry(login: "user#{page}")]
        }

        thread = Thread.new { user.followings }
        # Page 3 is asked for while page 2 is still waiting for its answer.
        2.times { Timeout.timeout(5) { started.pop } }
        2.times { release << true }

        expect(thread.value).to eq(%w(user1 user2 user3))
      end

      it 'does not fetch beyond MAX_FOLLOWER_PAGE_COUNT' do
        stub_const('User::MAX_FOLLOWER_PAGE_COUNT', 2)

        expect(user.followings).to eq(%w(user1 user2))
        expect(client).not_to have_received(:following).with('alice', page: 3)
      end

      it 'raises what a page raised' do
        allow(client).to receive(:following).with('alice', page: 2).and_raise(Octokit::Unauthorized)

        expect { user.followings }.to raise_error(Octokit::Unauthorized)
      end
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

      it 'does not ask GitHub again' do
        2.times { user.followings }

        expect(client).to have_received(:following).once
      end
    end

    context 'when they have been fetched before' do
      include ActiveSupport::Testing::TimeHelpers

      subject(:user) { create(:user, username: 'alice') }

      before do
        allow(client).to receive(:following).and_return([following_entry(login: 'bob')])
        user.followings
        allow(client).to receive(:following).and_return([following_entry(login: 'carol')])
      end

      it 'returns them without asking GitHub again' do
        expect(user.followings).to eq(%w(bob))
        expect(client).to have_received(:following).once
      end

      it 'returns them to whoever loads the user next' do
        loaded = User.find(user.id)
        allow(loaded).to receive(:github_client).and_return(client)

        expect(loaded.followings).to eq(%w(bob))
      end

      it 'does not return them for another user' do
        other = create(:user, username: 'dave')
        allow(other).to receive(:github_client).and_return(client)

        expect(other.followings).to eq(%w(carol))
      end

      it 'asks GitHub again once they expired' do
        travel User::FOLLOWINGS_EXPIRY + 1.minute do
          expect(user.followings).to eq(%w(carol))
        end
      end

      context 'with refresh: true' do
        it 'replaces them with what GitHub answers' do
          expect(user.followings(refresh: true)).to eq(%w(carol))
          expect(user.followings).to eq(%w(carol))
        end

        it 'keeps them when GitHub cannot be asked' do
          allow(client).to receive(:following).and_raise(Octokit::Unauthorized)

          expect { user.followings(refresh: true) }.to raise_error(Octokit::Unauthorized)
          expect(user.followings).to eq(%w(bob))
        end
      end
    end
  end
end
