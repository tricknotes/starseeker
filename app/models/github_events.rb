module GithubEvents
  include Typhoeus
  remote_defaults on_success: lambda {|response| JSON.parse(response.body) },
                  on_failure: lambda {|response| response.code },
                  base_uri: 'https://api.github.com'

  define_remote_method :received_event, path: '/users/:user/received_events'
end
