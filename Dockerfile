FROM ruby:3.3.6
RUN apt-get update -qq && apt-get install -y postgresql-client
RUN mkdir /app
WORKDIR /app

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
