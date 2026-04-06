describe StarEvent do
  describe '.fetch_and_upsert' do
    subject(:fetch) { StarEvent.fetch_and_upsert(token: token, logins: logins, since: since) }

    let(:token)  { 'test-token' }
    let(:since)  { 2.hours.ago }
    let(:logins) { ['alice'] }

    # ── Net::HTTP mock ──────────────────────────────────────────────────────────
    let(:http) { instance_double(Net::HTTP) }

    before do
      allow(Net::HTTP).to receive(:start).and_yield(http)
    end

    # Stub http to return a GraphQL JSON body.
    def stub_graphql(body)
      response = double(:http_response, body: body.to_json)
      allow(http).to receive(:request).and_return(response)
    end

    # ── GraphQL response builders ───────────────────────────────────────────────
    def graphql_response(data_hash)
      { 'data' => data_hash }
    end

    def starred_repositories_field(edges, has_next_page: false)
      {
        'starredRepositories' => {
          'edges'    => edges,
          'pageInfo' => { 'hasNextPage' => has_next_page, 'endCursor' => nil },
        }
      }
    end

    def edge(repo_name:, starred_at:, private: false, language: nil, stargazers: 10, description: 'A repo')
      owner = repo_name.split('/').first
      {
        'starredAt' => starred_at.iso8601,
        'node'      => {
          'nameWithOwner'   => repo_name,
          'isPrivate'       => private,
          'description'     => description,
          'primaryLanguage' => language ? { 'name' => language } : nil,
          'stargazerCount'  => stargazers,
          'owner'           => { 'login' => owner, 'avatarUrl' => "https://github.com/#{owner}.png" },
        },
      }
    end

    # ── happy path ──────────────────────────────────────────────────────────────
    context 'when a public repo is starred within the since window' do
      let(:starred_at) { 30.minutes.ago }

      before do
        stub_graphql graphql_response(
          'u0' => starred_repositories_field([
            edge(repo_name: 'bob/project', starred_at: starred_at, language: 'Ruby', stargazers: 42),
          ])
        )
      end

      it 'creates a StarEvent record' do
        expect { fetch }.to change { StarEvent.count }.by(1)
      end

      it 'stores the correct actor and timing' do
        fetch
        event = StarEvent.last
        expect(event.actor_login).to eq('alice')
        expect(event.repo_name).to eq('bob/project')
        expect(event.starred_at).to be_within(1.second).of(starred_at)
      end

      it 'creates a Repository record' do
        expect { fetch }.to change { Repository.count }.by(1)
        repo = Repository.find_by(name: 'bob/project')
        expect(repo.language).to eq('Ruby')
        expect(repo.stargazers_count).to eq(42)
      end
    end

    # ── private repo ────────────────────────────────────────────────────────────
    context 'when a repo is private' do
      before do
        stub_graphql graphql_response(
          'u0' => starred_repositories_field([
            edge(repo_name: 'alice/secret', starred_at: 30.minutes.ago, private: true),
          ])
        )
      end

      it 'does not create a StarEvent' do
        expect { fetch }.not_to change { StarEvent.count }
      end

      it 'does not create a Repository' do
        expect { fetch }.not_to change { Repository.count }
      end
    end

    # ── since threshold ─────────────────────────────────────────────────────────
    context 'when a repo was starred before the since threshold' do
      before do
        stub_graphql graphql_response(
          'u0' => starred_repositories_field([
            edge(repo_name: 'bob/old-project', starred_at: 3.hours.ago),
          ])
        )
      end

      it 'does not create a StarEvent' do
        expect { fetch }.not_to change { StarEvent.count }
      end
    end

    # ── mixed edges ─────────────────────────────────────────────────────────────
    context 'when edges contain both recent and old repos' do
      before do
        stub_graphql graphql_response(
          'u0' => starred_repositories_field([
            edge(repo_name: 'bob/recent', starred_at: 30.minutes.ago),
            edge(repo_name: 'bob/old',    starred_at: 3.hours.ago),
          ])
        )
      end

      it 'only upserts the recent star event' do
        fetch
        expect(StarEvent.pluck(:repo_name)).to contain_exactly('bob/recent')
      end
    end

    # ── missing data (org account / NOT_FOUND) ──────────────────────────────────
    context 'when GraphQL returns no data for a login (e.g. org account)' do
      before do
        stub_graphql graphql_response({ 'u0' => nil })
      end

      it 'does not raise and creates no records' do
        expect { fetch }.not_to raise_error
        expect(StarEvent.count).to eq(0)
      end
    end

    # ── multiple logins in one batch ────────────────────────────────────────────
    context 'with two logins in a single batch' do
      let(:logins) { ['alice', 'bob'] }

      before do
        stub_graphql graphql_response(
          'u0' => starred_repositories_field([edge(repo_name: 'carol/x', starred_at: 30.minutes.ago)]),
          'u1' => starred_repositories_field([edge(repo_name: 'carol/y', starred_at: 20.minutes.ago)]),
        )
      end

      it 'creates star events for each login' do
        fetch
        expect(StarEvent.pluck(:actor_login)).to contain_exactly('alice', 'bob')
      end

      it 'sends exactly one GraphQL HTTP request for the batch' do
        fetch
        expect(http).to have_received(:request).once
      end
    end

    # ── REST fallback when hasNextPage ──────────────────────────────────────────
    context 'when GraphQL reports hasNextPage (more starred repos than GRAPHQL_PAGE_SIZE)' do
      let(:fallback_client) { double(:octokit_client) }

      # Sawyer-like double for a REST starred item
      def rest_starred_item(repo_name:, starred_at:)
        owner = repo_name.split('/').first
        repo = double(
          :repo,
          full_name:        repo_name,
          description:      'desc',
          language:         'Ruby',
          stargazers_count: 5,
          owner:            double(:owner, login: owner, avatar_url: "https://github.com/#{owner}.png"),
        )
        allow(repo).to receive(:[]).with(:private).and_return(false)
        double(:starred_item, starred_at: starred_at.iso8601, repo: repo)
      end

      before do
        # GraphQL page 1: has a next page and has not reached since
        stub_graphql graphql_response(
          'u0' => starred_repositories_field(
            [edge(repo_name: 'bob/first', starred_at: 30.minutes.ago)],
            has_next_page: true
          )
        )

        # REST fallback returns one item then signals end of pages (size < per_page)
        allow(fallback_client).to receive(:starred).and_return(
          [rest_starred_item(repo_name: 'bob/extra', starred_at: 1.hour.ago)]
        )
      end

      it 'calls the REST fallback client to fetch remaining pages' do
        StarEvent.fetch_and_upsert(
          token:           token,
          logins:          logins,
          since:           since,
          fallback_client: fallback_client
        )
        expect(fallback_client).to have_received(:starred).at_least(:once)
      end

      it 'persists star events from both the GraphQL and REST paths' do
        StarEvent.fetch_and_upsert(
          token:           token,
          logins:          logins,
          since:           since,
          fallback_client: fallback_client
        )
        expect(StarEvent.pluck(:repo_name)).to contain_exactly('bob/first', 'bob/extra')
      end
    end

    # ── idempotency ─────────────────────────────────────────────────────────────
    context 'when the same star event is fetched twice' do
      before do
        stub_graphql graphql_response(
          'u0' => starred_repositories_field([
            edge(repo_name: 'bob/project', starred_at: 30.minutes.ago),
          ])
        )
      end

      it 'does not create duplicate records' do
        fetch
        expect { fetch }.not_to change { StarEvent.count }
      end
    end
  end
end
