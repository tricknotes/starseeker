require 'rake'

describe 'star_events:fetch' do
  let!(:user) { create(:user, :with_authentication, username: 'alice') }

  let(:client) { instance_double(Octokit::Client, access_token: 'GITHUB_TOKEN', last_response: instance_double(Sawyer::Response, rels: {})) }

  before(:all) do
    Rails.application.load_tasks unless Rake::Task.task_defined?('star_events:fetch')
  end

  before do
    allow_any_instance_of(User).to receive(:github_client).and_return(client)
    allow(StarEvent).to receive(:fetch_and_upsert)

    allow(client).to receive(:following).and_return([{ 'login' => 'bob', 'type' => 'User' }])
    user.followings
  end

  after do
    Rake::Task['star_events:fetch'].reenable
  end

  it 'refreshes the followings of each user and fetches the stars of them' do
    allow(client).to receive(:following).and_return([{ 'login' => 'carol', 'type' => 'User' }])

    Rake::Task['star_events:fetch'].invoke

    expect(StarEvent).to have_received(:fetch_and_upsert).with(hash_including(logins: %w(carol alice)))
    expect(user.followings).to eq(%w(carol))
  end

  it 'marks the token as revoked and keeps the followings when GitHub rejects it' do
    allow(client).to receive(:following).and_raise(Octokit::Unauthorized)

    Rake::Task['star_events:fetch'].invoke

    expect(StarEvent).not_to have_received(:fetch_and_upsert)
    expect(user.reload).to be_token_revoked
    expect(user.followings).to eq(%w(bob))
  end
end
