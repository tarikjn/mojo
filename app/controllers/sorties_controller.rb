class SortiesController < ApplicationController
  
  before_filter :require_user
  layout "userhome"
  
  def new
    @sortie = Sortie.new
  end
  
  def create
    @sortie = Sortie.new(params[:sortie])

    if @sortie.save
      redirect_to(@sortie, :notice => 'Sortie was successfully created.')
    else
      render :action => "new"
    end
  end
  
  def join
  
  end
  
  def confirmation
    @sortie = Sortie.find(params[:id])
  end
  
end
