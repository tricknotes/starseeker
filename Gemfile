source 'https://rubygems.org'

ruby '3.0.1'

gem 'rails', '~> 6.1.0.rc2'

gem 'hamlit'
gem 'mongoid'
gem 'octokit'
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-rails_csrf_protection'
gem 'pg'
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
