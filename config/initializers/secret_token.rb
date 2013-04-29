# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
Starseeker::Application.config.secret_key_base = ENV['SECRET_TOKEN'] || '9655c5fd9112b357c534c062a8998992e3c63b186f12062a383d19a95ad9d7c104eee48971642772c98b0353bcb3e4edb8279ee60ddc005b39765c567c7a6676'
