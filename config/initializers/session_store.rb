# Be sure to restart your server when you modify this file.

# Without expire_after, a session cookie stays valid forever once it leaks.
# The expiry is also embedded in the encrypted cookie and checked by the server,
# and the cookie is rewritten on every request, so this logs out idle users.
Rails.application.config.session_store :cookie_store, key: '_starseeker_session', expire_after: 2.weeks
