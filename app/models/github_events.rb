module GithubEvents
  include Typhoeus
  remote_defaults on_success: ->(response) { JSON.parse(response.body) },
                  on_failure: ->(response) { response.code },
                  base_uri: 'https://api.github.com'

  define_remote_method :followings, path: '/users/:user/following'
end
