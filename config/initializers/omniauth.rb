Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, Settings.github.client_id, Settings.github.secret
end
