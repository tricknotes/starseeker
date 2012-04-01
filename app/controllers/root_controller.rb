class RootController < ApplicationController
  def index
    @users = User.newly
  end
end
