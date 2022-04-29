FROM ruby:3.1.2
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
RUN mkdir /app
WORKDIR /app

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
