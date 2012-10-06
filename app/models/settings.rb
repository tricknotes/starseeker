class Settings < Settingslogic
  source "#{Rails.root}/config/settings.yml.default"
  source "#{Rails.root}/config/settings.yml" if File.exist?("#{Rails.root}/config/settings.yml")
  namespace Rails.env

  def host
    if uri.default_port == uri.port
      uri.host
    else
      '%s:%d' % [uri.host, uri.port]
    end
  end

  private
  def uri
    @uri ||= URI.parse(self.base_url)
  end
end
