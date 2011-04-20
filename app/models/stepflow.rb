# this is a "virtual" model, see: http://railscasts.com/episodes/219-active-model
# look maybe at using state_machine for fancy class :)
class Stepflow
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :step, :operation, :timerange, :complete
  
  #validates_presence_of
  validates_inclusion_of :operation, :in => %w( join create ), :message => "Please select <em>Create</em> or <em>Join</em>"
  
  # add default user, date creation
  # add basic validation
  
  def defaults
    self.step      ||= 0 # can be 0, 1, 2, 3 (done)
    self.timerange ||= {:day => Date.today.to_date, :time_start => "15:00", :time_end => "18:00"}
  end
  
  def timerange=(hash)
    if (hash.include?(:time_combined))
      times = hash[:time_combined].split(/-/)
      @timerange = {:day => hash[:day], :time_start => times[0], :time_end => times[1]}
    else
      @timerange = hash
    end
  end
  
  def update(attributes)
    self.attributes = attributes
  end
  
  # move to next step
  def move_next
    if self.valid?
      
      # init some new defaults in here
      case self.step
      when 0, 1
        
        case self.step
        when 0
          
          case self.operation
          when 'join'
            # create activity result object on selected geo

            # respond ajax/json for map refresh

            @activities = Activity.find_activities_for_user(current_user)
          when 'create'

            # not much to do
            #@user = session[:user]

          end
          
        when 1
          
          # profile/review step
          # profile: # set up dob year based on age

          # actually need to be refactored: it's a submit...
          case self.operation
          when 'join'
            #session[:selected_dates] = params[:dates]


          when 'create'

          end
          
        end
        
        # common for step 0 and 1
        self.step += 1
        'next'
      when 2
        # finish...
        # do save etc. call separate action?
        self.complete = {'create' => 'created', 'join' => 'joined'}[self.operation]
        'redirect'
      end
    else
      'error'
    end
  end
  
  # refactoring
  def discover_submit
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
    # need follow-up to confirm date
    # add friend to buddies
  end
  def join_submit
    
    session[:selected_dates] = params[:dates]
    
    # quick & dirty testing
    
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
    
  end
  def review_submit
    
    # add user to waitlists => move to model
    selected_dates = session[:selected_dates]
    selected_dates.each{ |d| Activity.find(d).add_entrant(current_user) }
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
    
  end
  
  # move to previous step
  def move_prev
    self.step -= 1
    'prev'
  end
  
  def initialize(attributes = {})
    self.attributes = attributes
    
    # call defaults after initialize
    defaults
  end
  
  def attributes=(attributes)
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
  
end