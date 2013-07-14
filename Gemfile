source 'https://rubygems.org'

ruby '2.0.0'

# Bundle edge Rails instead:
# # gem 'rails', github: 'rails/rails'-
gem 'rails', '~> 4.0.0'

# for local
gem 'sqlite3', groups: %w(test development), require: false

# for heroku
gem 'pg', groups: %w(production), require: false

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 4.0.0'
  gem 'coffee-rails', '~> 4.0.0'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.3.0'
end

gem 'settingslogic'

gem 'jquery-rails'
gem 'haml-rails'
gem 'roadie'

gem 'omniauth'
gem 'omniauth-github'
gem 'mongoid', github: 'mongoid/mongoid', ref: 'fe7f43430580860db6d1d89cea27eda24ab60ab1'
gem 'bson_ext'
gem 'octokit'

gem 'redis'

group :development do
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'tapp', groups: %w(test)
  gem 'letter_opener'
end
gem 'puma', require: false

group :test do
  gem 'rspec-rails', groups: %w(development)
  gem 'capybara'
  gem 'factory_girl_rails'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano', group: :development

# To use debugger
# gem 'debugger'
