# Setup stub data for star events.

raise "'\033[31mproduction\033[39m' should not be sutubed." if Rails.env.production?

GITHUB_LOGIN = ENV['GITHUB_LOGIN']
unless GITHUB_LOGIN
  raise "The environment variable `\033[31mGITHUB_LOGIN\033[39m` is required."
end

StarEvent.delete_all

def star_event_from_path(path)
  data = JSON.parse(File.read(path))
  StarEvent.new(data.except('id'))
end

fixture_path = Rails.root.join('spec', 'fixtures', 'watch_events')

github_client = Settings.github_client

# Setup star event from `GITHUB_LOGIN`
data_path = fixture_path.join('*.json').to_s
Dir[data_path].each.with_index do |path, n|
  star_event = star_event_from_path(path)

  @user ||= github_client.user(GITHUB_LOGIN)
  keys = star_event.actor.keys
  star_event.actor = @user.to_hash.with_indifferent_access.extract!(*keys)

  star_event.created_at = n.days.ago.strftime(StarEvent::DATETIME_FORMAT)
  star_event.save!
  puts "Stub event: '\033[36m%s\033[39m' starred by \033[36m%s\033[39m" % [star_event['repo']['name'], star_event['actor']['login']]
end

# Setup star event to `GITHUB_LOGIN`
Dir[data_path].each.with_index do |path, n|
  star_event = star_event_from_path(path)

  @following ||= github_client.following(GITHUB_LOGIN)
  star_event.actor = @following.sample.to_hash.with_indifferent_access.extract!(*star_event.actor.keys)
  @repos ||= github_client.repos(GITHUB_LOGIN)
  repo = @repos.sample
  star_event.repo['id']   = repo['id']
  star_event.repo['name'] = repo['full_name']
  star_event.repo['url']  = repo['url']

  star_event.created_at = n.hours.ago.strftime(StarEvent::DATETIME_FORMAT)
  star_event.save!
  puts "Stub event: '\033[36m%s\033[39m' starred by \033[36m%s\033[39m" % [star_event['repo']['name'], star_event['actor']['login']]
end
