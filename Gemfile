source 'https://rubygems.org'

ruby '2.0.0'

# Bundle edge Rails instead:
# # gem 'rails', github: 'rails/rails'-
gem 'rails', '~> 4.0.0.beta1'

# for local
gem 'sqlite3', groups: %w(test development), require: false

# for heroku
gem 'pg', groups: %w(production), require: false

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 4.0.0.beta1'
  gem 'coffee-rails', '~> 4.0.0.beta1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

gem 'settingslogic'

gem 'jquery-rails'
gem 'haml-rails'
gem 'haml', '~> 4.0.1.rc1'
gem 'roadie', github: 'Mange/roadie'

gem 'sorcery', github: 'NoamB/sorcery'
gem 'mongoid', github: 'mongoid/mongoid'
gem 'bson_ext'
gem 'octokit'

group :development do
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'binding_of_caller'
end
gem 'puma', require: false

group :test do
  gem 'rspec-rails', groups: %w(development)
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'webmock'
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
