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
    # Cloudflare injects the Web Analytics beacon into every page. It is
    # allowed by host because the script path varies by version
    # (beacon.min.js/v...). Its data goes to /cdn-cgi/rum on this host.
    policy.script_src      :self, 'https://static.cloudflareinsights.com'
    policy.style_src       :self
    # Signing in posts to /auth/github, which redirects to GitHub, and
    # browsers apply form-action to that redirect as well.
    policy.form_action     :self, 'https://github.com'
    policy.frame_ancestors :none
  end
end
