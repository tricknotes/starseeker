class Settings < Settingslogic
  source "#{Rails.root}/config/settings.yml" if File.exist?("#{Rails.root}/config/settings.yml")
  source "#{Rails.root}/config/settings.yml.default"
  namespace Rails.env

  def url_options
    {
      host: uri.host,
      port: uri.default_port == uri.port ? nil : uri.port
    }
  end

  def github_client
    @github_client ||= if self.github['login'] && self.github['token']
      Octokit::Client.new(
        login: self.github.login,
        oauth_token: self.github.token
      )
    else
      Octokit::Client.new
    end
  end

  private
  def uri
    @uri ||= URI.parse(self.base_url)
  end
end
