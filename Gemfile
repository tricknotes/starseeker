source 'https://rubygems.org'

ruby '2.7.0'

gem 'rails', '~> 6.0.0'

gem 'hamlit'
gem 'mongo', '~> 2.8.0' # For 'mongod version: 3.6.12 (MMAPv1)'
gem 'mongoid'
gem 'octokit', github: 'octokit/octokit.rb' # Workaround for waiting new release. https://github.com/octokit/octokit.rb/issues/1177
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
  gem 'letter_opener'
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
