class UserhomeController < ApplicationController
  
  before_filter :require_user
  
  def index
    @user = current_user
  end

  def dates
    @open_sorties = current_user.open_sorties
    @upcoming_dates = current_user.upcoming_dates
  end
  
  def settings
    @user = current_user
  end
  # TODO: move to its user controller
  def update_settings
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to(:action => "settings", :notice => 'Your settings were successfully updated.')
    else
      render :action => "settings"
    end
  end
end
