class SortieReportsController < ApplicationController
  
  before_filter :require_user
  layout "userhome"
  
  def new
    # TODO: check if sortie is eligible for report and user has rights: add as filter for both action
    @report = SortieReport.new(:sortie_id => params[:date_id], :by_id => current_user.id)
    # @report.sortie.members.each do |u|
    #       # when displayed by the form as a checkbox, the form should not pass any data if not checked
    #       # otherwise a nested attibute is build
    #       @report.culprits << u
    #     end
    # TODO: only add review of opposite party
    @report.sortie.dates_of(@report.by).each do |u|
      @report.user_ratings << UserRating.new(:user => u)
      @report.picture_ratings << PictureRating.new(:user => u)
    end
    @report.place_review = PlaceReview.new(:place => @report.sortie.place)
    @report.site_review = SiteReview.new
  end

  def create
    params[:sortie_report][:culprit_ids] ||= []
    @report = SortieReport.new(params[:sortie_report].merge(:sortie_id => params[:date_id], :by_id => current_user.id))
    
    if @report.save
      flash[:notice] = "You're done! Thank you a bunch!"
      
      redirect_to dates_url
    else
      render :action => :new
    end
  end

end
