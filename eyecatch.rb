serve 'bin/rails server'
port 3000

service 'postgresql'
service 'mongodb'
service 'redis'

before_build {
  run 'gem update bundler --no-rdoc --no-ri'
  run 'bundle install --without development:production'
  run 'bin/rake db:create db:schema:load'
}

task(:anonymous) {
  entry_point '/'
  exclude_paths ['/auth/github']
}
