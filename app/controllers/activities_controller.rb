class ActivitiesController < ApplicationController
  
  before_filter :require_user
  layout "userhome"
  
  def new
    @activity = Activity.new
  end
  
  def create
    @activity = Activity.new(params[:activity])

    if @activity.save
      redirect_to(@activity, :notice => 'Activity was successfully created.')
    else
      render :action => "new"
    end
  end
  
  def join
  
  end
  
  def confirmation
    @activity = Activity.find(params[:id])
  end
  
end
