source 'https://rubygems.org'

ruby '3.1.0'

gem 'rails', '~> 6.1.0'

gem 'hamlit'
gem 'mongoid'
gem 'net-imap' # Missing gem for mail. Ref: https://github.com/mikel/mail/pull/1439
gem 'net-pop' # Same as above
gem 'net-smtp' # Same as above
gem 'octokit'
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-rails_csrf_protection'
gem 'pg'
gem 'psych', '~> 3.0' # To avoid Rails 6.1 & YAML 4 issue: https://github.com/ruby/psych/pull/487
gem 'puma', require: false
gem 'redis'
gem 'roadie-rails'
gem 'sassc-rails'
gem 'settingslogic'
gem 'uglifier'

group :development do
  gem 'letter_opener_web'
  gem 'listen'
  gem 'pry', groups: %i(test)
  gem 'pry-rails', groups: %i(test)
  gem 'rexml' # To use letter_opener_web on Ruby 3.0. Ref: https://github.com/fgrehm/letter_opener_web/pull/106
  gem 'tapp', groups: %i(test)
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'rspec-its'
  gem 'rspec-rails', groups: %i(development)
end
