# Setup stub data for star events.

raise "'\033[31mproduction\033[39m' should not be stubbed." if Rails.env.production?

GITHUB_LOGIN = ENV['GITHUB_LOGIN']
unless GITHUB_LOGIN
  raise "The environment variable `\033[31mGITHUB_LOGIN\033[39m` is required."
end

StarEvent.delete_all
Repository.delete_all

github_client = Settings.github_client
user = github_client.user(GITHUB_LOGIN)
following = github_client.following(GITHUB_LOGIN)
repos = github_client.repos(GITHUB_LOGIN)

# Setup star events from `GITHUB_LOGIN`
starred = github_client.starred(
  GITHUB_LOGIN,
  sort: 'created',
  direction: 'desc',
  per_page: 10,
  headers: { accept: 'application/vnd.github.v3.star+json' }
)

starred.each do |item|
  repo = item.repo
  star_event = StarEvent.create!(
    actor_login: user.login,
    actor_avatar_url: user.avatar_url,
    repo_name: repo.full_name,
    starred_at: item.starred_at
  )
  Repository.find_or_create_by!(name: repo.full_name) do |r|
    r.description = repo.description
    r.language = repo.language
    r.stargazers_count = repo.stargazers_count
    r.owner_login = repo.owner.login
    r.owner_avatar_url = repo.owner.avatar_url
  end
  puts "Stub event: '\033[36m%s\033[39m' starred by \033[36m%s\033[39m" % [star_event.repo_name, star_event.actor_login]
end

# Setup star events to `GITHUB_LOGIN` (followings starring user's repos)
following.sample(5).each_with_index do |follower, n|
  repo = repos.sample
  next unless repo

  star_event = StarEvent.create!(
    actor_login: follower.login,
    actor_avatar_url: follower.avatar_url,
    repo_name: repo.full_name,
    starred_at: n.hours.ago
  )
  Repository.find_or_create_by!(name: repo.full_name) do |r|
    r.description = repo.description
    r.language = repo.language
    r.stargazers_count = repo.stargazers_count
    r.owner_login = repo.owner.login
    r.owner_avatar_url = repo.owner.avatar_url
  end
  puts "Stub event: '\033[36m%s\033[39m' starred by \033[36m%s\033[39m" % [star_event.repo_name, star_event.actor_login]
end
