class SortiesController < ApplicationController
  
  before_filter :require_user
  layout "userhome"
  
  def index
    @past_sorties = current_user.past_sorties
    @upcoming_sorties = current_user.upcoming_sorties
    @open_sorties = current_user.open_sorties
    @entered_sorties = current_user.entered_sorties
  end
  
  def new
    @sortie = Sortie.new
    @sortie.time = Time.now + 2.days # make it work with time zones
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
    @timerange = TimeRange.new((Date.today + 1.day).strftime("%F"), "12:00", "21:00")
    @sorties = Sortie.find_sorties_for_user(current_user)
    @upcoming_sorties = current_user.upcoming_sorties
  end
  
  def join
    @sorties = (params[:sorties])? Sortie.find(params[:sorties]) : []
    if @sorties.size > 0
      @sorties.each do |s|
        s.add_entrant(current_user)
      end
      redirect_to(dates_url, :notice => "Your successfully joined #{ActionView::Helpers::TextHelper.pluralize(@sorties.size, 'date')}!")
    else
      @single_error = "Please select at least one date!"
      # TODO: refactor this into an special initilizer
      @timerange = TimeRange.new(params['timerange(1s)'], params['timerange(2s)'], params['timerange(3s)'])
      @sorties = Sortie.find_sorties_for_user(current_user)
      @upcoming_sorties = current_user.upcoming_sorties
      render :action => :search
    end
  end
  
  def confirmation
    @sortie = Sortie.find(params[:id])
  end
  
  def cancel
    @sortie = Sortie.find(params[:id])
    if @sortie.cancel(current_user)
      flash[:notice] = "Your date has been canceled."
    else
      flash[:error] = "Action forbidden."
    end
    redirect_to(dates_url)
  end
  
end
