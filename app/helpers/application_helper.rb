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

  # +account+ is anything that responds to #login and #avatar_url:
  # a User, a Repository::Owner (Repository#owner, StarEvent#actor), ...
  def image_link_to_github_url(account, size = '30x30')
    link_to avatar_image_tag(account, size), github_url(account.login)
  end

  def avatar_image_tag(account, size)
    image_tag(account.avatar_url, title: account.login, alt: account.login, size: size)
  end

  def html_title_about_user(user)
    user.username + (user.name.present? ? (' (%s)' % user.name) : '')
  end
end
