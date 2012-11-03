class RootController < ApplicationController
  def index
    @users = User.order('RANDOM()').limit(15)
  end
end
