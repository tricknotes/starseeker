source 'https://rubygems.org'

ruby '2.6.0'

gem 'rails', '~> 5.2.0'

gem 'hamlit'
gem 'mongoid'
gem 'mongo'
gem 'octokit'
gem 'omniauth'
gem 'omniauth-github'
gem 'pg', groups: %i(production), require: false
gem 'puma', require: false
gem 'redis'
gem 'roadie-rails'
gem 'sass-rails'
gem 'settingslogic'
gem 'uglifier'

group :development do
  gem 'letter_opener'
  gem 'listen'
  gem 'pry', groups: %i(test)
  gem 'pry-rails', groups: %i(test)
  gem 'tapp', groups: %i(test)
  gem 'web-console'
  gem 'sqlite3', '~> 1.3.6', groups: %i(test) # 1.4.0 causes loading error
end

group :test do
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'rspec-its'
  gem 'rspec-rails', groups: %i(development)
end
