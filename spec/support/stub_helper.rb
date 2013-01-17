module StubHelper

  FIXTURE_PATH = Rails.root.join('spec', 'fixtures')

  def stub_star_event!(attrs)
    json = FIXTURE_PATH.join('watch_events', '1.json').read
    event = JSON.parse(json)
    event = event.merge('created_at' => DateTime.now.strftime(StarEvent::DATETIME_FORMAT))
    StarEvent.create!(event.merge(attrs))
  end

  def stub_repository!(name, attrs = {})
    json = FIXTURE_PATH.join('repositories', '1.json').read
    repo = JSON.parse(json)
    repo = repo.merge(attrs).merge('full_name' => name)
    stub_request(:get, URI.join(Octokit.api_endpoint, 'repos/' + name).to_s)
      .to_return(body: repo)
    Repository.fetch!(name)
  end
end

RSpec.configuration.include StubHelper, capybara_feature: true
