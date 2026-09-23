class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic

  default from: "starseeker <noreply@#{Settings.url_options[:host]}>"
  layout 'mailer'
end
