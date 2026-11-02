FROM ruby:4.0.9
RUN apt-get update -qq && apt-get install -y postgresql-client
# The Bundler bundled with the base image lags behind BUNDLED WITH, and
# `bundle update` would otherwise rewrite the lockfile to the older version.
RUN gem install bundler
RUN mkdir /app
WORKDIR /app

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
