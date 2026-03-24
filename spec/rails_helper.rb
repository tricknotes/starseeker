require 'spec_helper'

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!
  config.infer_base_class_for_anonymous_controllers = false

  config.before :each do
    StarEvent.destroy_all
    Repository.destroy_all
  end

  config.before :each do
    clear_mail_box
  end

  config.after :each do
    OmniAuth.config.mock_auth.delete :github
  end

  config.include FactoryBot::Syntax::Methods
end
