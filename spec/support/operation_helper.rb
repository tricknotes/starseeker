module OperationHelper
  def clear_mail_box
    ActionMailer::Base.deliveries.clear
  end
end

RSpec.configuration.include OperationHelper
