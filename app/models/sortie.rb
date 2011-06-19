# Sortie is used instead of Date because date is a reserved ruby/rails keyword
class Sortie < ActiveRecord::Base
  include ActiveModelExtensions # Mojo's
  
  belongs_to :host, :foreign_type => 'host_type', :polymorphic => true
  belongs_to :guest, :foreign_type => 'guest_type', :polymorphic => true
  belongs_to :place
  
  has_many :entries, :dependent => :destroy
  has_many :updates, :class_name => "SortieUpdate"
  has_many :sortie_reports
  
  validates :title, :presence => true
  validates :place, :presence => true
  validates_inclusion_of :size, :in => [2, 4]
  validates_inclusion_of :state, :in => %w(unconfirmed open canceled closed expired)
  validates_inclusion_of :category, :in => %w(food_and_drinks entertainment outdoor)
  
  attr_accessor :location
  
  # GeoKit
  acts_as_mappable :through => :place
  
  # scopes
  scope :future, lambda { { :conditions => ["time > ?", Time.now] } } # 'time' column likely to pose an issue with SQL
  scope :active, lambda { where('time < ? and time > ?', Time.now + 2.hours, Time.now - 1.hour) }
  scope :closed, where(:state => 'closed')
  scope :with_user, lambda { |user| where('(size = 2 AND (host_id = :user OR guest_id = :user)) OR (size = 4 AND (host_id = :wings OR guest_id = :wings))', 
    {:user => user.id, :wings => Wing.ids_with(user)}) }
  
  def report_by(user)
    self.sortie_reports.where(:by => user)
  end
  
  def creator
    # do as a has_one :through?
    (self.host.is_a? User)? self.host : self.host.lead
  end
  
  def party_of(party)
    # check if the party is in the sortie at all?
    self.host == party ? self.guest : self.host
  end
  
  def location=(location_id)
    provider_id = location_id.match(/^[a-z]+-[a-z]+-(.+)$/)[1]
    self.place = Place.where({:kind => 'business', :provider => 'yelp', :provider_id => provider_id}).first
  end
  
  def location
    if self.place
      "business-yelp-#{self.place.provider_id}"
    else
      nil
    end
  end
  
  def update_state
    # figure out if state of sortie changed
    if (self.state == 'open')
      # probably there is a cleaner way to do that
      if self.guest
        self.close()
      end
    end
  end
  
  def close
    # entrants have been invited, sortie is confirmed/no longer accepts entries
    
    # send confirmations to hosts and guests
    Notifier::invited_confirmation(self, self.guest)
    
    # set up SMS service?
    self.start_sms # async
    
    # update state
    self.state = 'closed'
    
    # commit
    self.save
  end
  
  def get_people
    people = [self.host, self.guest]
    # refactor for doubles
    #people += [self.creator_invitee.host, self.creator_invitee.participant] if self.invitee_duo
    people
  end
  
  # called when a user asks to join the date
  def add_entrant(user)
    # add user to entries
    entry = Entry.new(:sortie => self, :party => user)
    entry.save
    
    # notification send should be in entries?
    # restructure: should send 2 emails for double dates
    Notifier.new_entrant(self, self.creator).deliver
  end
  
  # perform is a special command sent by the scheduler, we use it to inform SMS service is now active for the date
  def start_sms
    msg = "Hi! Your date with %s is in 2 hours, you can now chat to sync any details etc., just respond to this number! Happy Dating :) Mojo."
    
    # sent msg to host
    Sms.deliver(self.host.cellphone, msg % self.guest.first_name)
    # sent msg to guest
    Sms.deliver(self.guest.cellphone, msg % self.host.first_name)
  end
  # 5.minutes.from_now will be evaluated when in_the_future is called
  handle_asynchronously :start_sms, :run_at => Proc.new { self.time - 2.hours }
  
  def cancel(user)
    if ['open', 'closed', 'unconfirmed'].include?(self.state) and self.host_id == user.id
      self.updates << SortieUpdate.new(:kind => 'cancel', :by => user)
      self.state = 'canceled'
      self.save
      true
    else
      false
    end
  end
  
  def open?
    self.state == 'open'
  end
  
  def upcoming?
    self.state == 'closed' and self.time > Time.now
  end
  
  def past?
    self.time < Time.now
  end
  
  def has_tasks?
    self.open? and self.entries.size > 0
  end
  
  #####
  # Static methods
  ##
  def self.find_sorties_for_user(user)
    # TODO: eliminate your own sorties or sorties you already joined
    # add filtering
    self.find(:all, :conditions => ["time > ?", Time.now])
      
    # Geokit radius:
    # Store.find(:all, :origin =>[37.792,-122.393], :within=>10)
  end
  
  def self.find_active_sortie_for(user)
    
    # look for the sortie that is within 2 hours from now or less than 1 hour ago
    # this is used by the SMS controller
    self.active.with_user(user)
    
    # it is the role of the entry/sortie invite actions to make sure that no user can have 2 active dates at the same time
    
  end
  
  def self.open_sorties_for(user)
    # find the open sorties where these wings are hosts or the user host himself (single dates)
    self.future.where(:host_id => Wing.ids_with(user), :size => 4, :state => 'open') + self.future.where(:host_id => user, :size => 2, :state => 'open')
  end
  
  def self.upcoming_sorties_for(user)
    # find the closed upcoming sorties where the user is in
    self.future.closed.with_user(user)
    # ["time > ", Time.now]
  end
end
