module StubHelper
  def stub_star_event!(attrs)
    actor = attrs[:actor] || {}
    repo = attrs[:repo] || {}

    repo_name = repo[:name] || repo['name']
    StarEvent.create!(
      actor_login: actor[:login] || actor['login'],
      actor_avatar_url: actor[:avatar_url] || actor['avatar_url'],
      repo_name: repo_name,
      repo_owner: repo_name&.split('/')&.first,
      starred_at: attrs[:starred_at] || Time.current
    )
  end

  def stub_repository!(name, attrs = {})
    owner_login = name.split('/').first

    Repository.create!(
      name: name,
      description: attrs[:description],
      language: attrs[:language],
      stargazers_count: attrs[:watchers_count] || attrs[:stargazers_count],
      owner_login: owner_login,
      owner_avatar_url: attrs[:owner_avatar_url] || "https://github.com/#{owner_login}.png"
    )
  end
end

RSpec.configuration.include StubHelper
