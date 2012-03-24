class DashboardController < ApplicationController
  before_filter :require_login, :assing_curent_user

  def show
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      redirect_to dashboard_path, notice: 'Successfully updated.'
    else
      render action: 'edit'
    end
  end

  private

  def assing_curent_user
    @user = current_user
  end
end
