class RootController < ApplicationController
  def index
    @users = User.order('RANDOM()').limit(25)
  end
end
