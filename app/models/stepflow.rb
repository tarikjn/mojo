# this is a "virtual" model, see: http://railscasts.com/episodes/219-active-model
# look maybe at using state_machine for fancy class :)
class Stepflow
  include ActiveModel::Validations
  include ActiveModel::Conversion
  #include ActiveModel::NestedAttributes
  extend ActiveModel::Naming
  
  ASSOCIATED = [:host, :friend, :sortie]
  
  attr_accessor :step, :operation, :timerange, :complete,
                :party_of, :host, :friend,
                :sortie, :sorties, # sortie to be created, or sorties to be joined, how to validate activites?? -> custom validation
                :disabled_validations
  
  #validates_presence_of
  validates_inclusion_of :operation, :in => %w( join create ), :message => "Please select <em>Create</em> or <em>Join</em>"
  validates :party_of, :inclusion => { :in => %w( single double ) }
  
  # ported back to ActiveModel for this in validations.rb
  validates_active_associated ASSOCIATED
  
  # add default user, date creation
  # add basic validation
  
  def defaults
    default_pass = 'demo'
    
    self.step      ||= 0 # can be 0, 1, 2, 3 (done)
    @timerange     ||= TimeRange.new(Date.today.strftime("%F"), "15:00", "18:00")
    self.party_of  ||= 'single'
    self.host      ||= User.new( :completeness => 'discovery', :password => default_pass ) # can receive current_user from the controller
    self.friend    ||= User.new( :completeness => 'invite' ) # only validate if it's a single date
  end
  
  def active_validations
    validations = []
    
    case self.step
    when 0
      validations << :host
      validations << :friend if self.party_of == 'double'
    when 1
      validations << :sortie if self.operation == 'create'
    when 2
      validations << :host
    end
    Logger.new(STDOUT).info("Active V.: " + validations.inspect)
    validations
  end
  
  def clear_associated_errors
    inactives = ASSOCIATED - self.active_validations # only clear inactives
    inactives.each do |a|
      member = self.send(a)
      member.clear_errors if member
    end
  end
  
  # refactor using rails standard function in ActiveRecord
  def timerange=(arg)
    @timerange = TimeRange.new(arg["(1s)"], arg["(2s)"], arg["(3s)"])
  end
  
  def update(attributes)
    self.attributes = attributes
  end
  
  #class_eval
  #if method_defined?(:#{association_name}_attributes=)
  #remove_method(:#{association_name}_attributes=)
  #end
  #def #{association_name}_attributes=(attributes)
  #  assign_nested_attributes_for_#{type}_association(:#{association_name}, attributes)
  #end
  
  # set private with other methods?
  # TODO: introduce allias of accepts_nested_attributes_for
  def host_attributes=(attributes)
    self.host.attributes = attributes
  end
  
  def friend_attributes=(attributes)
    self.friend.attributes = attributes
  end
  
  def sortie_attributes=(attributes)
    self.sortie.attributes = attributes
  end
  
  def sorties=(array)
    array.each do |a|
      @sorties << Sortie.find(a)
    end
  end
  
  # move to next step
  def move_next
    
    # before validation, clear validation residues
    self.clear_associated_errors
    
    Logger.new(STDOUT).info("Step: " + self.step.to_s)
    Logger.new(STDOUT).info("Sortie object before validation: " + self.sortie.inspect)
    if self.valid?
      
      # init some new defaults in here
      case self.step
      when 0, 1
        
        case self.step
        when 0
          
          case self.operation
          when 'join'
            # create sortie result object on selected geo

            # respond ajax/json for map refresh

            #@sorties = Sortie.find_sorties_for_user(current_user)
            @sorties ||= []
            
          when 'create'

            # not much to do
            #@user = session[:user]
            self.sortie ||= Sortie.new( :time => self.timerange.start )
            Logger.new(STDOUT).info(self.sortie.inspect)

          end
          
        when 1
          
          # switch to full validation for user, TODO: revert, refactor for existing usser...
          self.host.completeness = 'complete' if self.host.completeness == 'discovery'
          
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
        self.save_associated
        # do save etc. call separate action?
        self.complete = {'create' => 'created', 'join' => 'joined'}[self.operation]
        'complete'
      end
    else
      Logger.new(STDOUT).info("Stepflow Validation Errors: " + self.errors.full_messages.inspect)
      'error'
    end
  end
  
  def save_associated
    # everything is supposed to be valid...
    
    # implement somewhere else
    #if friend ->
    #  complete profile
    #  confirm friendship (add other friends)
    #  accept date
    #-> post date
    
    #joining:
    # waiting entry wait for same things...
    
    # assuming single date, new user.... TODO: implement all cases
    
    # save host
    self.host.save
    
    # create Duo for host
    duo = Duo.new(:host => self.host)
    
    case self.operation
    when 'join'
      self.sorties.each do |a|
        a.add_entrant(self.host)
      end
    
    when 'create'
      # set sortie state, TODO: maybe do in the stepflow process?
      self.sortie.state = 'open'
      # set sortie duo
      self.sortie.creator_duo = duo
      # save sortie
      self.sortie.save
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
    
    # create temporary sortie object
    sortie = Sortie.new({
      :category => params[:type],
      :title => params[:title],
      :description => params[:description],
      :time => params[:obj][:time],
      :state => 'unactive'
    })
    
    session[:sortie] = sortie
    
  end
  def review_submit
    
    # add user to waitlists => move to model
    selected_dates = session[:selected_dates]
    selected_dates.each{ |d| Sortie.find(d).add_entrant(current_user) }
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
    # prettier way to do that?
    return if attributes.nil?
    
    attributes.each do |name, value|
      Logger.new(STDOUT).info(name.inspect)
      Logger.new(STDOUT).info(value.inspect)
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
  
end

# TODO: move to Lib
class TimeRange
  attr_reader :start, :end
  
  # make class method
  def parse_time(s)
    e = s.split(/:/)
    e[0].to_i.hours + e[1].to_i.minutes
  end
  
  # # will receive 1s, 2s, 3s from Controller
  def initialize(day, time_start_or_range, time_end = nil)
    if (time_end.nil?) # receiving combined time range
      time_start_or_range, time_end = time_start_or_range.split(/-/)
    end
    
    date = Date.parse(day)
    @start = date + self.parse_time(time_start_or_range)
    @end = date + self.parse_time(time_end)
  end

end
