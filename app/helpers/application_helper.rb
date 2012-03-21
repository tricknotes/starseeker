module ApplicationHelper
  def gravatar_url(gravatar_id)
    "https://secure.gravatar.com/avatar/#{gravatar_id}?s=140&d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-140.png"
  end

  def github_url(name)
    "https://github.com/#{name}"
  end
end
