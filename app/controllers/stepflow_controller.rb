class StepflowController < ApplicationController
  
  def discover
    # GET: we are getting here from the homepage
    #@params = params[:obj]
    
    #@def_startdate = params[:obj][:start_time]
    #@def_enddate = params[:obj][:end_time]
    
    @step = 0
    @remaining = '2 more minutes'
  end
  
  def discover_submit
    # remove
    @params = params
    
    # set location and timeframe preference in session
    # create temporary user object with user info
    user = User.new ({
      :sex => params[:sex],
      :sex_preference => params[:sex_preference],
      :dob => params[:age], # some processing required here
      :min_age => params[:min_age],
      :max_age => params[:max_age],
      :height => params[:height], # process height with function
      :min_height => params[:min_height], # same
      :max_height => params[:max_height] # same
    })
    
    # set up friend's user object and send follow-up email
    # neeed follow-up to confirm date
    
    # store in session before any redirect, don't if coming back from next step
    session[:user] = user
    
    # TODO: check data input, currently unsafe!!!
    op = params[:operation]
    if !op
      # any error? redisplay form
      render "discover"
    else
      # all good? display join or create form
      #redirect_to :action => op
      
      # quick & dirty testing
      @step = 1
      @remaining = '1 more minute'
      @previous_action = '/stepflow/discover'
      respond_to do |format|
        format.html { redirect_to :action => op }
        format.js {
          render :json => {
            :move => 'next',
            :action => '/stepflow/' + op,
            :block => render_to_string(op),
            :nav => render_to_string(:partial => "nav")
          }, :content_type => 'application/json'
        }
      end
    end
    
  end
  
  def discover_search
    # this action is for getting number of activities matching for join
    @params = params
    render "discover"
  end
  
  def join
    
    # create activity result object on selected geo
    
    # respond ajax/json for map refresh
    
    @step = 1
    @remaining = '1 more minute'
    @previous_action = '/stepflow/discover'
    
    @activities = Activity.find_activities_for_user(current_user)
    
  end
  
  def join_submit
    
    session[:selected_dates] = params[:dates]
    
    # quick & dirty testing
    @step = 2
    @remaining = '5 seconds'
    @previous_action = '/stepflow/join'
    
    current_action = '/stepflow/review'
    
    respond_to do |format|
      format.html { redirect_to :action => current_action }
      format.js {
        render :json => {
          :move => 'next',
          :action => current_action,
          :block => render_to_string(current_action),
          :nav => render_to_string(:partial => "nav")
        }, :content_type => 'application/json'
      }
    end
    
  end
  
  def review
  
  end
  
  def review_submit
    
    # add user to waitlists
    selected_dates = session[:selected_dates]
    selected_dates.each{ |d| Activity.find(d).add_entrant(current_user) }
    
    current_action = '/stepflow/finish'
    
    respond_to do |format|
      format.html { redirect_to :action => current_action }
      format.js {
        render :json => {
          :move => 'redirect', # any of next, prev, redirect, error
          :redirect_path => path_to_url(current_action)
        }, :content_type => 'application/json'
      }
    end
  end
  
  def finish
    @selected_dates = session[:selected_dates]
    render :layout => 'application'
    
    # clear session data?
  end
  
  def create
    
    # not much to do
    @user = session[:user]
    
    @step = 1
    @remaining = '1 more minute'
    @previous_action = '/stepflow/discover'
  end
  
  def create_submit
    
    # create temporary activity object
    activity = Activity.new({
      :activity_type => params[:type],
      :title => params[:title],
      :description => params[:description],
      :time => params[:obj][:time],
      :state => 'unactive'
    })
    
    session[:activity] = activity
    
    # all good? direct to profile
    redirect_to :action => 'profile'
    
  end
  
  def profile
    
    # set up dob year based on age
    
    @step = 2
    @remaining = '30 more seconds'
    @previous_action = '/stepflow/create'
  end
  
  def profile_submit
    
    # create temporary user object
    user = session[:user]
    user.attributes = {
      :first_name => params[:first_name],
      :last_name => params[:last_name],
      :email => params[:email],
      :cellphone => params[:cellphone],
      :picture_url => nil # not implemented yet
    }
    
    # save all objects!
    
    # redirect to confirmation page (join or create)
    redirect_to :action => 'created'
    
  end
  
  def created
    PhoneService.deliver("+16506449308", "This is Mojo Monkey!")
  end
  
  def map
    flash[:list] = params[:p]
    #@step = 1
    #@previous_action = ''
  end
  
private
  # methods for re-using code here
  
end
