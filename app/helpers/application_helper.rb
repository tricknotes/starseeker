module ApplicationHelper
  def gravatar_url(gravatar_id)
    "https://secure.gravatar.com/avatar/#{gravatar_id}?s=140&d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-140.png"
  end

  def github_url(*name)
    "https://github.com/#{name.join('/')}"
  end

  def link_to_repo(repo_name)
    link_to repo_name, github_url(repo_name)
  end

  def link_to_stargazers(repo)
    link_to('[%d]' % repo.stargazers_count, github_url(repo.full_name, 'stargazers'))
  end

  def image_link_to_github_url(user, size = '30x30')
    username = user.is_a?(User) ? user.username : user['login']

    link_to gravatar_image_tag(user, size), github_url(username)
  end

  def gravatar_image_tag(user, size)
    username, avatar_url = if user.is_a?(User)
      [user.username, user.avatar_url]
    else
      [user['login'], gravatar_url(user['gravatar_id'])]
    end

    tag('img', src: avatar_url, title: username, alt: username, width: size, height: size)
  end

  def image_link_to_github_url_from_event(event)
    image_link_to_github_url(event['actor'])
  end

  def html_title_about_user(user)
    user.username + (user.name.present? ? (' (%s)' % user.name) : '')
  end
end
