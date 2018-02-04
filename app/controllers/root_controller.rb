class RootController < ApplicationController
  def index
    @users = User.email_sendables.randomly.limit(25)
  end
end
