FROM ruby:4.0.2
RUN apt-get update -qq && apt-get install -y postgresql-client
RUN mkdir /app
WORKDIR /app

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
