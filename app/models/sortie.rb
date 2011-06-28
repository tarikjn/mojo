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
  scope :past, lambda { { :conditions => ["time < ?", Time.now - 15.minutes] } }
  scope :future, lambda { { :conditions => ["time > ?", Time.now] } } # 'time' column likely to pose an issue with SQL
  scope :active, lambda { where('time < ? and time > ?', Time.now + 2.hours, Time.now - 1.hour) }
  scope :closed, where(:state => 'closed')
  scope :open, where(:state => 'open')
  scope :hosted_by, lambda { |user|
    where('(size = 2 AND host_id = :user) OR (size = 4 AND host_id = :wings)',
      {:user => user.id, :wings => Wing.ids_with(user)})
  }
  scope :with_user, lambda { |user|
    where('(size = 2 AND (host_id = :user OR guest_id = :user)) OR (size = 4 AND (host_id = :wings OR guest_id = :wings))',
      {:user => user.id, :wings => Wing.ids_with(user)})
  }
  scope :without_entries_with, lambda { |user|
    # for performance/scaling, the right thing to do would be to have a table with the list of dates a user has joined? Or select entries first and then sorties from there
    where('(SELECT count(sortie_id) FROM entries WHERE sorties.id = entries.sortie_id AND entries.party_type = ? AND entries.party_id = ? AND entries.state NOT IN (?)) = 0', 'User', user.id, %w(withdrawn overridden))
  }
  scope :not_within_schedule_of, lambda { |user|
    # this is quite ugly! need to find a more elegant way to write that
    where('(
    SELECT COUNT(*) FROM sorties up WHERE up.state = :state
    AND ((up.size = 2 AND (up.host_id = :user OR up.guest_id = :user)) OR (up.size = 4 AND (up.host_id = :wings OR up.guest_id = :wings)))
    AND sorties.time > '+((Rails.env == 'development')? "datetime(up.time, '-2 hours')":"up.time - INTERVAL '2 hours'")+'
    AND sorties.time < '+((Rails.env == 'development')? "datetime(up.time, '+1 hour')":"up.time + INTERVAL '1 hour'")+'
    ) = 0',
    {:state => 'closed', :user => user.id, :wings => Wing.ids_with(user), :start => '-2 hours', :end => '+1 hour'})
  }
  # would be nice to have somethign returning the schedule on a user and then simply querying for what is not in there...
  scope :for_filters, lambda { |user|
    #where(:users => {:sex_preference => user.sex, :sex => user.sex_preference}).joins(:host)
    # {:joins => :host, :conditions => ["users.sex_preference = ? AND users.sex = ?", user.sex, user.sex_preference] }
    #     :joins => :country, :conditions => 
    #     ['popular_resort = ?', true], :order => 'countries.name ASC'
    #User.match_for(user)
    #where(:all, :conditions => [''], :join => :host)
    #where(:users => {:sex => 'male'}).joins(:host)
    #joins(:host).where('users.id = sorties.host_id')
    #where("host_type = 'User'").includes( [ { :host => [:user, {:subtopic=>:category}] } , :user] )
    #[{:flaggable=>[:user,{:subtopic=>:category}]},:user]
    # 
    
    # would be great to delegate the user scope part to User.match_for(user), how to do that?
    # see http://stackoverflow.com/questions/6147052/should-i-drop-a-polymorphic-association?
    { :joins => 'INNER JOIN users ON users.id = host_id',
      :conditions => ['host_type = ? AND sex_preference IN (?) AND sex IN (?)', 'User', ['both', user.sex], user.looking_for] }
    
  }
  
  after_create :set_expiration
  
  def report_by(user)
    self.sortie_reports.where(:by_id => user).first
  end
  
  def creator
    # do as a has_one :through?
    (self.host.is_a? User)? self.host : self.host.lead
  end
  
  def party_of(party) #pluralize for double dates
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
        self.close!()
      end
    end
  end
  
  def close!
    # entrants have been invited, sortie is confirmed/no longer accepts entries
    
    # send confirmations to hosts and guests
    Notifier::invited_confirmation(self, self.guest).deliver
    
    # set up  SMS service?
    self.send_at(self.time - 2.hours, :start_sms) # async, move time setting to settings.yml
    
    # update state
    self.state = 'closed'
    
    # commit
    self.save
  end
  
  def set_expiration
    self.send_at(self.time, :start_or_update_state!)
  end
  
  def start_or_update_state!
    if self.state == 'open'
      
      # no one entered the sortie and it expired
      self.state = 'expired'
      self.save
      
    elsif state == 'closed'
      
      # the sortie is expected to be happening now
      
      # TODO: schedule other job to email end_of_sortie notification
      
    end
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
    if self.upcoming? # check that the sortie has not been canceled
      msg = "Hi! Your date with %s is in #{ ActionView::Helpers::DateHelper.distance_of_time_in_words Time.now, self.time }, you can now chat to sync any details etc., just respond to this number! Happy Dating :) Mojo."
    
      # sent msg to host
      Sms.deliver(self.host.cellphone, msg % self.guest.first_name)
      # sent msg to guest
      Sms.deliver(self.guest.cellphone, msg % self.host.first_name)
    end
  end
  # 5.minutes.from_now will be evaluated when in_the_future is called
  #handle_asynchronously :start_sms, :run_at => Proc.new { self.time - 2.hours }
  
  def cancel(user)
    if ['open', 'closed', 'unconfirmed'].include?(self.state) and self.host_id == user.id
      
      # record cancellation
      self.updates << SortieUpdate.new(:kind => 'cancel', :by => user)
      
      # send notification to party if the date was already scheduled!
      Notifier::date_canceled(self, user, self.party_of(user)).deliver if self.state == 'closed'
      
      # change the state to canceled
      self.state = 'canceled'
      
      # commit
      self.save
      
      # success, is this needed? save returns true, no?
      true
    else
      false
    end
  end
  
  def open?
    self.state == 'open' and self.time > Time.now
  end
  
  def upcoming?
    self.state == 'closed' and self.time > Time.now
  end
  
  def completed?
    self.state == 'closed' and self.time < Time.now
  end
  
  def has_tasks_for?(user)
    if self.open?
      # any entries to go through?
      self.entries.waiting.size > 0
    elsif self.completed?
      # report completed?
      self.report_by(user)? false : true
    else
      false
    end
  end
  
  #####
  # Static methods
  ##
  def self.find_sorties_for_user(user) # this is used by date search
    
    # filtering open, future dates where the user is not host or didn't enter (except withdrawn, overridden)
    self.future.open.where('size = 2 AND host_id != ?', user.id).without_entries_with(user).for_filters(user).not_within_schedule_of(user)
    
    # also eliminate dates happening when you already have dates scheduled
    
    # where -> replace with not_hosted_by(user)
      
    # Geokit radius:
    # Store.find(:all, :origin =>[37.792,-122.393], :within=>10)
  end
  
  def self.find_active_sortie_for(user)
    
    # look for the sortie that is within 2 hours from now or less than 1 hour ago
    # this is used by the SMS controller
    self.active.with_user(user).first
    
    # it is the role of the entry/sortie invite actions to make sure that no user can have 2 active dates at the same time
    
  end
  
  def self.open_sorties_for(user)
    # find the open sorties where these wings are hosts or the user host himself (single dates)
    self.future.open.hosted_by(user)
  end
  
  def self.upcoming_sorties_for(user)
    # find the closed upcoming sorties where the user is in
    self.future.closed.with_user(user)
    # ["time > ", Time.now]
  end
  
  def self.past_sorties_for(user)
    self.past.closed.with_user(user)
  end
end
