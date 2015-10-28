source 'https://rubygems.org'

ruby '2.2.3'

# Bundle edge Rails instead:
# # gem 'rails', github: 'rails/rails'-
gem 'rails', '~> 4.2.0'

# for local
gem 'sqlite3', groups: %w(test development), require: false

# for heroku
gem 'pg', groups: %w(production), require: false

gem 'sass-rails'
gem 'coffee-rails'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer'

gem 'uglifier'

gem 'settingslogic'

gem 'jquery-rails'
gem 'haml-rails'
gem 'roadie-rails'

gem 'omniauth'
gem 'omniauth-github'
gem 'mongoid', github: 'mongodb/mongoid' # To use https://github.com/mongodb/mongoid/pull/4179
gem 'octokit'

gem 'redis'

group :development do
  gem 'quiet_assets'
  gem 'web-console'
  gem 'tapp', groups: %w(test)
  gem 'pry', groups: %w(test)
  gem 'letter_opener'
end
gem 'puma', require: false

group :test do
  gem 'rspec-rails', groups: %w(development)
  gem 'rspec-its'
  gem 'capybara'
  gem 'factory_girl_rails'
end

group :production do
  gem 'rails_12factor' # for Heroku
end
