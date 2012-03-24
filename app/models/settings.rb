class Settings < Settingslogic
  source "#{Rails.root}/config/settings.yml.default"
  source "#{Rails.root}/config/settings.yml" if File.exist?("#{Rails.root}/config/settings.yml")
  namespace Rails.env
end
