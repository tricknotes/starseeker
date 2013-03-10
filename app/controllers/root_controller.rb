class RootController < ApplicationController
  def index
    @users = User.email_sendables.order('RANDOM()').limit(25)
  end
end
