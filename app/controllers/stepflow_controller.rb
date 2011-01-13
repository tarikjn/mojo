require 'phone_service'

class StepflowController < ApplicationController
  
  def discover
    # GET: we are getting here from the homepage
    #@params = params[:obj]
    
    #@def_startdate = params[:obj][:start_time]
    #@def_enddate = params[:obj][:end_time]
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
      redirect_to :action => op
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
    
  end
  
  def create
    
    # not much to do
    @user = session[:user]
    
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
    PhoneService.send_sms
  end
  
  def map
    flash[:list] = params[:p]
  end

end
