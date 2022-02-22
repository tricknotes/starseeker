source 'https://rubygems.org'

ruby '3.1.1'

gem 'rails', '~> 7.0.2'

gem 'hamlit'
gem 'mongoid', github: 'mongodb/mongoid' # To use https://github.com/mongodb/mongoid/pull/5122
gem 'octokit'
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-rails_csrf_protection'
gem 'pg'
gem 'psych', '~> 3.0' # To avoid Settinglogics & YAML 4 issue: https://github.com/ruby/psych/pull/487
gem 'puma', require: false
gem 'redis'
gem 'roadie-rails'
gem 'sassc-rails'
gem 'settingslogic'
gem 'sprockets-rails'
gem 'uglifier'

group :development do
  gem 'letter_opener_web'
  gem 'listen'
  gem 'pry', groups: %i(test)
  gem 'pry-rails', groups: %i(test)
  gem 'tapp', groups: %i(test)
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'rspec-its'
  gem 'rspec-rails', groups: %i(development)
end
