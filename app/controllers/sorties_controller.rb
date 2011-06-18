class SortiesController < ApplicationController
  
  before_filter :require_user
  layout "userhome"
  
  def index
    @past_sorties = current_user.past_sorties
    @upcoming_sorties = current_user.upcoming_sorties
    @open_sorties = current_user.open_sorties
  end
  
  def new
    @sortie = Sortie.new
  end
  
  def create
    @sortie = Sortie.new(params[:sortie])
    @sortie.host = current_user
    @sortie.state = 'open'

    if @sortie.save
      redirect_to(dates_url, :notice => 'Your date was successfully created!')
    else
      render :action => "new"
    end
  end
  
  def search
    @sorties = {
      'timerange' => TimeRange.new(Date.today.strftime("%F"), "15:00", "18:00")
    }
    @find_sorties = Sortie.find_sorties_for_user(current_user)
  end
  
  def confirmation
    @sortie = Sortie.find(params[:id])
  end
  
end
