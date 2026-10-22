# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src     :self
    policy.base_uri        :self
    policy.font_src        :self
    # Avatars and the "Fork me" ribbon are served from GitHub's hosts.
    policy.img_src         :self, :https
    policy.object_src      :none
    policy.script_src      :self
    policy.style_src       :self
    # Signing in posts to /auth/github, which redirects to GitHub, and
    # browsers apply form-action to that redirect as well.
    policy.form_action     :self, 'https://github.com'
    policy.frame_ancestors :none
  end
end
