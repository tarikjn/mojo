# Activity is used instead of Date because date is a reserved ruby/rails keyword
class Activity < ActiveRecord::Base
  include ActiveModelExtensions # Mojo's
  
  belongs_to :creator_duo, :class_name => "Duo"
  belongs_to :invitee_duo, :class_name => "Duo"
  belongs_to :place
  has_many :waitlist_entries
  
  validates :title, :presence => true
  validates :place, :presence => true
  validates_inclusion_of :state, :in => %w(unactive open canceled closed)
  validates_inclusion_of :category, :in => %w(food_and_drinks entertainment outdoor)
  
  # GeoKit
  acts_as_mappable :through => :place
  
  # TODO: add shortcut of type activity.creator => activity.creator_duo.host
  def creator
    # do as a has_one :through?
    self.creator_duo.host
  end
  
  def invitee
    self.invitee_duo.host
  end
  
  def hosts
    # return both creator and invitee
  end
  
  def location=(location_id)
    provider_id = location_id.match(/^[a-z]+-[a-z]+-(.+)$/)[1]
    self.place = Place.where({:kind => 'business', :provider => 'yelp', :provider_id => provider_id}).first
  end
  
  def update_state
    # figure out if state of activity changed
    if (self.state == 'open')
      # probably there is a cleaner way to do that
      # !self.invitee_duo assume we assing 2 duos for activities
      if (self.creator_duo.participant and (!self.invitee_duo or (self.invitee_duo and self.invitee_duo.participant)))
        self.close()
      end
    end
  end
  
  def close
    # entrants have been invited, activity is confirmed/no longer accepts entries
    
    # send confirmations to co-hosts and participants
    Notifier::invited_confirmation(self, self.creator_duo.participant)
    
    # set up SMS service?
    self.start_sms # async
    
    # update state
    self.state = 'closed'
    
    #commit
    self.save
  end
  
  def get_people
    people = [self.creator_duo.host, self.creator_duo.participant]
    people += [self.creator_invitee.host, self.creator_invitee.participant] if self.invitee_duo
    people
  end
  
  def location_district
    # use yelp API, TODO: replace with GeoPlanet? or put badge link to yelp...
    # need to cache results 100 limit right now
    cache = ActiveSupport::Cache::MemoryStore.new
    cache.fetch("date_#{self.id}_district") do
      # API request
      response = HTTParty.get("http://api.yelp.com/neighborhood_search?lat=#{self.lat}&long=#{self.lng}&ywsid=#{SETTINGS[Rails.env]['YWSID']}")
      puts response.body, response.code, response.message, response.headers.inspect
      
      # return value (get stored in cache too)
      # decoding JSON manually, Yelp not sending json header format
      resp = ActiveSupport::JSON.decode(response.body)
      
      if (resp['message']['code'] == 0)
        resp['neighborhoods'][0]['name']
      else # exceeded max daily limit
        "Exceeded daily limit (Yelp)"
      end
    end
  end
  
  # called when a user asks to join the date
  def add_entrant(user)
    # add user to waitlist_entries
    entry = WaitlistEntry.new(:activity => self, :user => user)
    entry.save
    
    # notification send should be in waitlist_entries?
    # restructure: should send 2 emails for double dates
    Notifier.new_entrant(self, self.creator).deliver
  end
  
  def self.find_activities_for_user(user)
    if (user.id == 1)
      return self.find(6,7,8)
    else
      # TODO: eliminate your own activities or activities you already joined
      # add filtering
      self.find(:all, :conditions => ["time > ?", Time.now])
    end
    # Geokit radius:
    # Store.find(:all, :origin =>[37.792,-122.393], :within=>10)
  end
  
  def self.find_active_activity_for(user)
    # implement
    # testing: first open activity
    self.upcoming_activities_for(user).last
  end
  
  def self.open_activities_for(user)
    # find Duos where the user is
    duos = Duo.find(:all, :conditions => ["host_id = ? OR participant_id = ?", user.id, user.id])
    # find the open activities where these duos are hosts
    self.where(:creator_duo_id => duos, :state => 'open')
  end
  
  def self.upcoming_activities_for(user)
    # find Duos where the user is
    duos = Duo.find(:all, :conditions => ["host_id = ? OR participant_id = ?", user.id, user.id])
    # find the open activities where these duos are hosts
    self.where(:creator_duo_id => duos, :state => 'closed') # ["time > ", Time.now]
  end
  
  # perform is a special command sent by the scheduler, we use it to inform SMS service is now active for the date
  def start_sms
    msg = "Hi! Your date with %s is in 2 hours, you can now chat to sync any details etc., just respond to this number! Happy Dating :) Mojo."
    
    # sent msg to host
    Sms.deliver(self.creator_duo.host.cellphone, msg % self.creator_duo.participant.first_name)
    # sent msg to participant
    Sms.deliver(self.creator_duo.participant.cellphone, msg % self.creator_duo.host.first_name)
  end
  # 5.minutes.from_now will be evaluated when in_the_future is called
  handle_asynchronously :start_sms, :run_at => Proc.new { 30.seconds.from_now }
end
