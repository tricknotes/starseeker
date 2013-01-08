source 'https://rubygems.org'

ruby '2.0.0'

gem 'rails', github: 'rails/rails'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# for local
gem 'sqlite3', groups: %w(test development), require: false

# for heroku
gem 'pg', groups: %w(production), require: false

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   github: 'rails/sass-rails'
  gem 'coffee-rails', github: 'rails/coffee-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

gem 'settingslogic'

gem 'jquery-rails'
gem 'haml-rails'
# gem 'roadie' # TODO To be enabled when it supported rails4

gem 'sorcery', github: 'NoamB/sorcery'
gem 'protected_attributes', github: 'rails/protected_attributes'
gem 'mongoid', github: 'mongoid/mongoid', branch: '4.0.0-dev'
gem 'bson_ext'
gem 'octokit'
gem 'rails-observers'

group :development do
  gem 'quiet_assets', github: 'evrone/quiet_assets'
  gem 'better_errors'
end
gem 'puma', require: false

group :test do
  gem 'rspec-rails', groups: %w(development)
  gem 'factory_girl_rails'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
