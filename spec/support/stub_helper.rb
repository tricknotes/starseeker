module StubHelper

  FIXTURE_PATH = Rails.root.join('spec', 'fixtures')

  def stub_star_event!(attrs)
    json = FIXTURE_PATH.join('watch_events', '1.json').read
    event = JSON.parse(json)
    event = event.merge('created_at' => DateTime.now.strftime(StarEvent::DATETIME_FORMAT))
    StarEvent.create!(event.merge(attrs))
  end

  def stub_repository!(name, attrs = {})
    json = FIXTURE_PATH.join('repositories', '1.json').read
    repo = JSON.parse(json)
    repo = repo.merge(attrs).merge('full_name' => name)
    stub_request(:get, URI.join(Octokit.api_endpoint, 'repos/' + name).to_s)
      .to_return(body: repo)
    Repository.fetch!(name)
  end

  def stub_login!(user)
    # Stub '#login_at' in '/oauth/:provider'
    original_login_at = OauthsController.instance_method(:login_at)
    OauthsController.send(:define_method, :login_at) do |provider|

      redirect_to action: :callback, provider: provider

      # Remove stub
      OauthsController.send(:define_method, :login_at) do |provider|
        original_login_at.bind(self).call(provider)
      end
    end

    # Stub `#login_from` in '/oauth/callback'
    original_login_from = OauthsController.instance_method(:login_from)
    OauthsController.send(:define_method, :login_from) do |provider|
      auto_login(user)
      after_login!(user)

      # Remove stub
      OauthsController.send(:define_method, :login_from) do |provider|
        original_login_from.bind(self).call(provider)
      end

      user
    end
  end
end

RSpec.configuration.include StubHelper, capybara_feature: true
