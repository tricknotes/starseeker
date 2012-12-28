source 'https://rubygems.org'

ruby '1.9.3'

gem 'rails', '3.2.9'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# for local
gem 'sqlite3', groups: %w(test development), require: false

# for heroku
gem 'pg', groups: %w(production), require: false

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'

  gem 'turbo-sprockets-rails3'
end

gem 'settingslogic'

gem 'jquery-rails'
gem 'haml-rails'
gem 'roadie'

gem 'sorcery', github: 'NoamB/sorcery'
gem 'mongoid'
gem 'bson_ext'
gem 'octokit'

group :development do
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'binding_of_caller' # for better_errors' advanced features
end
gem 'thin', require: false

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
