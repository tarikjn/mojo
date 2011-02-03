class Activity < ActiveRecord::Base
  belongs_to :creator_duo, :class_name => "Duo"
  belongs_to :invitee_duo, :class_name => "Duo"
  has_many :waitlist_entries
  
  validates_inclusion_of :state, :in => %w(open closed canceled)
  validates_inclusion_of :activity_type, :in => %w(food_and_drinks entertainment outdoor)
  
  # GeoKit
  acts_as_mappable :default_units => :miles, 
                   :default_formula => :sphere, 
                   :distance_field_name => :distance,
                   :lat_column_name => :lat,
                   :lng_column_name => :lng
  
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
  
  def location_district
    # use yelp API
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
    end
    # Geokit radius:
    # Store.find(:all, :origin =>[37.792,-122.393], :within=>10)
  end
end
