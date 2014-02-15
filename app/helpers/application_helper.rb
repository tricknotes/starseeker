module ApplicationHelper
  def github_url(path = '/', query = nil)
    path = '/' + path unless path[0] == '/'

    uri = URI.parse('https://github.com')
    uri.path = path
    uri.query = query.to_query if query
    uri.to_s
  end

  def link_to_repo(repo_name)
    link_to repo_name, github_url(repo_name)
  end

  def link_to_language(repo)
    return '' unless repo.language

    link_to "##{repo.language}", github_url('trending', l: repo.language)
  end

  def link_to_stargazers(repo)
    link_to('[%d]' % repo.stargazers_count, github_url("#{repo.full_name}/stargazers"))
  end

  def image_link_to_github_url(user, size = '30x30')
    username = user.is_a?(User) ? user.username : user['login']

    link_to gravatar_image_tag(user, size), github_url(username)
  end

  def gravatar_image_tag(user, size)
    username, avatar_url = if user.is_a?(User)
      [user.username, user.avatar_url]
    else
      user.values_at('login', 'avatar_url')
    end

    image_tag(avatar_url, title: username, alt: username, size: size)
  end

  def image_link_to_github_url_from_event(event)
    image_link_to_github_url(event['actor'])
  end

  def html_title_about_user(user)
    user.username + (user.name.present? ? (' (%s)' % user.name) : '')
  end
end
