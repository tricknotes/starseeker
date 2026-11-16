Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # The rake tasks report progress and per-user failures only through
  # Rails.logger, so forward it to Sentry Logs to see them next to errors.
  config.enabled_patches << :logger

  # Keep every trace locally so a test request is always visible, but sample
  # in production to stay within the quota.
  config.traces_sample_rate = Rails.env.production? ? 0.1 : 1.0
end
