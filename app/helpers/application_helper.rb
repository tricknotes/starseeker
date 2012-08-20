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

  def link_to_watchers(repo)
    link_to('[%d]' % repo.watchers_count, github_url(repo.full_name, 'watchers'))
  end

  def image_link_to_github_url(user)
    link_to image_tag(gravatar_url(user['gravatar_id']), size: '20x20'), github_url(user['login'])
  end

  def image_link_to_github_url_from_event(event)
    image_link_to_github_url(event['actor'])
  end
end
