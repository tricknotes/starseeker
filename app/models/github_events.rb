module GithubEvents
  def self.followings(options)
    response = Typhoeus.get('https://api.github.com/users/' + options.delete(:user) + '/following', options)
    status = response.code
    if 200 <= status && status < 300
      JSON.parse(response.body)
    else
      []
    end
  end
end
