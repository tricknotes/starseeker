# Deprecate: This module is for migration from settingslogic.
module Settings
  class << self
    def base_url
      ENV['BASE_URL']
    end

    def redis_url
      ENV['REDIS_URL']
    end

    def url_options
      {
        host: uri.host,
        port: uri.default_port == uri.port ? nil : uri.port
      }
    end

    def github_client
      @github_client =
        begin
          if ENV['GITHUB_LOGIN'] && ENV['GITHUB_TOKEN']
            Octokit::Client.new(
              login: ENV['GITHUB_LOGIN'],
              access_token: ENV['GITHUB_TOKEN'],
            )
          else
            Octokit::Client.new
          end
        end
    end

    private

    def uri
      @uri ||= URI.parse(base_url.to_s)
    end
  end
end
