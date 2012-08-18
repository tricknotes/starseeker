module ApplicationHelper
  def gravatar_url(gravatar_id)
    "https://secure.gravatar.com/avatar/#{gravatar_id}?s=140&d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-140.png"
  end

  def github_url(*name)
    "https://github.com/#{name.join('/')}"
  end

  def github_button(repo, type = 'watch')
    username, reponame = repo.split('/')
    button = <<-BUTTON
    <iframe src="http://markdotto.github.com/github-buttons/github-btn.html?user=#{username}&repo=#{reponame}&type=#{type}&count=true&size"
      allowtransparency="true" frameborder="0" scrolling="0" width="110px" height="20px"></iframe>
    BUTTON
    raw(button)
  end

  def link_to_repo(repo_name)
    link_to repo_name, github_url(repo_name)
  end

  def image_link_to_github_url(user)
    link_to image_tag(gravatar_url(user['gravatar_id']), size: '20x20'), github_url(user['login'])
  end

  def image_link_to_github_url_from_event(event)
    image_link_to_github_url(event['actor'])
  end
end
