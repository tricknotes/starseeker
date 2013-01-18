module StubHelper

  FIXTURE_PATH = Rails.root.join('spec', 'fixtures')

  def unique_id
    @unique_id ||= rand(10000)
    @unique_id += 1
  end

  def stub_star_event!(attrs)
    json = FIXTURE_PATH.join('watch_events', '1.json').read
    event = JSON.parse(json)
    event = event.merge(
      'id' => unique_id,
      'created_at' => DateTime.now.strftime(StarEvent::DATETIME_FORMAT)
    )
    StarEvent.create!(event.merge(attrs))
  end

  def stub_repository!(name, attrs = {})
    json = FIXTURE_PATH.join('repositories', '1.json').read
    repo = JSON.parse(json)
    repo = repo.merge(
      'id' => unique_id,
      'full_name' => name
    )
    repo = repo.merge(attrs)
    Repository.create!(repo)
  end
end

RSpec.configuration.include StubHelper
