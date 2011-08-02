class User < ActiveRecord::Base
  #include ActiveModelExtensions # Mojo's
  
  # should be used soon for security
  #attr_accessible :first_name, :last_name, :email, :invitation_token, :sex, :dob, :picture, :cellphone, :height, 
  #:sex_preference, :filter_age, :min_age, :max_age, :filter_height, :min_height, :max_height
  
  has_many :entries, :as => :party
  has_many :entered_sorties, :through => :entries, :source => :sortie, :as => :party
  
  # problem: how to do hosted_sorties both for single sorties and through wings
  
  #has_many :hosted_single_sorties, :source => :sortie, :as => :host
  #has_many :invited_single_sorties, :source => :sortie, :as => :guest
  
  # reports made by the user
  has_many :authored_reports, :class_name => "SortieReport", :foreign_key => "by_id"
  # these are reports where the user is tagged as "culprit"
  has_and_belongs_to_many :received_reports, :class_name => "SortieReport", :join_table => "sortie_reports_culprits"
  
  has_many :picture_ratings #, :conditions => ["picture_file_name = ?", self.picture], nop actually
  has_many :ratings, :class_name => "UserRating"
  
  has_many :hosted_sorties, :class_name => "Sortie", :as => :host
  
  # :generate_password is not so secure but practical, can be made more secure
  before_create :set_invitations_left, :generate_password # when adding invitation instances, this need to be hacked
  
  # AuthLogic
  # Switch to Rails' SecurePassword after upgrading to Rails 3.1?
  acts_as_authentic do |config|
    # we already have a RFC-compliant validation for email, damn Authlogic tries to do too much
    config.validate_email_field = false
    # set to true in the signup to allow auto password-generation
    config.ignore_blank_passwords = false
  end
  #
  # (solution from: http://stackoverflow.com/questions/2174082/force-validation-of-blank-passwords-in-authlogic/3703742#3703742)
  # object level attribute overrides the config level attribute
  # replaced ignore_blank_passwords with require_password?
  def require_password?
    require_password.nil? ? super : require_password
  end
  #
  # check for current password when doing a normal password change
  attr_accessor :generated_password, :current_password, :validate_current_password, :require_password, :height, :min_height, :max_height, :cellphone_format
  #attr_writer :current_password #needed?
  validate :current_password_valid, :on => :update, :if => :validate_current_password
  #
  # (solution from http://stackoverflow.com/questions/3580992/ruby-on-rails-authlogic-gem-password-confirmation-only-for-password-reset-and/3590455#3590455)
  def current_password_valid
    # valid_password? (Authlogic) checks current_password against database
    errors.add(:current_password, 'is incorrect') unless valid_password?(current_password)
  end
  
  # switched from Paperclip to CarrierWave
  mount_uploader :picture, PictureUploader
  
  # add state machine for stepflow/discovery state (object not saved)
  validates :state, :inclusion => { :in => %w(invitation active blocked) }
  validates :level, :inclusion => { :in => %w(user admin) }
  validates :email, :presence => true, :uniqueness => true, :email => true
  validates :first_name, :presence => true, :if => :active?
  validate :validate_age
  # picture fails with marshaling (stepflow issue)
  validates :picture, :presence => true, :if => :active?
  validates :cellphone, :presence => true, :format => {:with => /^(\+\d{1,3})?[-. ]?\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/}, :if => :active?
  validates :sex, :inclusion => { :in => %w(male female), :message => "Please select" }
  validates :sex_preference, :inclusion => { :in => %w(female both male), :message => "Please select" }
  # height is in milimeters
  
  # overrides access to db height attribute
  # somehow the write converter are not working, they are hand coded bellow
  composed_of :height, :class_name => 'Height', :mapping => %w(height height),
              :allow_nil => true, :converter => Proc.new { |hash| Height.create(hash) }
  composed_of :min_height, :class_name => 'Height', :mapping => %w(min_height height),
              :allow_nil => true, :converter => Proc.new { |hash| Height.create(hash) }
  composed_of :max_height, :class_name => 'Height', :mapping => %w(max_height height),
              :allow_nil => true, :converter => Proc.new { |hash| Height.create(hash) }
  
  # friendship TODO: add :dependant => :destroy?         
  has_many :friendships
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :direct_friends, :through => :friendships, :conditions => ["approved = ?", true], :source => :friend
  has_many :inverse_friends, :through => :inverse_friendships, :conditions => ["approved = ?", true], :source => :user

  has_many :pending_friends, :through => :friendships, :conditions => ["approved = ?", false], :foreign_key => "user_id", :source => :user
  has_many :requested_friendships, :class_name => "Friendship", :foreign_key => "friend_id", :conditions => ["approved = ?", false]
  
  # following
  has_many :follows, :foreign_key => "follower_id", :dependent => :destroy
  has_many :following, :through => :follows, :source => :followed
  has_many :reverse_follows, :foreign_key => "followed_id", :class_name => "Follow", :dependent => :destroy
  has_many :followers, :through => :reverse_follows, :source => :follower
  
  # invitations
  validates :invitation_id, :presence => {:message => 'is required'}, :uniqueness => true
  # todo if an invitation user exists, load that user/update...
  has_many :sent_invitations, :class_name => 'Invitation', :foreign_key => 'sender_id'
  belongs_to :invitation
  
  # scopes
  scope :registered, :conditions => ["state != ?", 'invitation']
  scope :match_for, lambda { |user|
    where(:sex_preference => user.sex, :sex => user.sex_preference).join(:hosted_sorties)
  }
  
  after_create :add_email_to_list, :if => lambda { |u| u.active? }
  after_update :clear_foodia, :update_email_in_list

  # move to EventMachine
  # TODO: make it work with invites/requests system
  def after_signup
    self.add_email_to_list
  end
  def after_changes
    self.update_email_in_list
  end

  def friends
    direct_friends | inverse_friends
  end
  
  def following?(followed)
    follows.find_by_followed_id(followed)
  end

  def follow!(followed)
    follows.create!(:followed_id => followed.id) unless related?(followed)
  end
  
  def unfollow!(followed)
    follows.find_by_followed_id(followed).destroy
  end
  
  # this helps make Users work well together with Wings
  def individuals
    [self]
  end
  
  # TODO: secure active and admin attributes with attr_accessible?
  # Authlogic checks this
  def active?
    state == 'active'
  end
  
  def admin?
    level == 'admin'
  end
  
  def related?(user)
    self == user or self.friends.include?(user)
  end
  
  def invitation_token
    invitation.token if invitation
  end

  def invitation_token=(token)
    self.invitation = Invitation.find_by_token(token)
  end
  
  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end
  
  def validate_age
    errors.add :dob, 'you need to be at least 18' if 18.years.ago < self.dob
  end
  
  def possessive
    self.sex == 'male'? 'his' : 'her'
  end
  
  # for SQL scopes
  def looking_for
    sex_preference == 'both'? ['male', 'female'] : [sex_preference]
  end
  
  # TODO: find a way to remove these, the converter should make it unecessary
  # somehow required for stepflow but otherwise break things
  # def height=(hash)
  #     @height = Height.create(hash)
  #     self[:height] = @height.nil? ? nil : @height.height
  #   end
  #   def min_height=(hash)
  #     @min_height = Height.create(hash)
  #     self[:min_height] = @min_height.nil? ? nil : @min_height.height
  #   end
  #   def max_height=(hash)
  #     @max_height = Height.create(hash)
  #     self[:max_height] = @max_height.nil? ? nil : @max_height.height
  #   end
  
  # weird instance varialbe issue, fix or use Phone Class
  def cellphone
    @cellphone = self[:cellphone] if @cellphone.nil?
    m = /^\+\d(\d{3})(\d{3})(\d{4})$/.match(@cellphone)
    m.nil? ? @cellphone:"(#{m[1]}) #{m[2]}-#{m[3]}"
  end
  def cellphone=(phone)
    m = /^(\+\d{1,3})?[-. ]?\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/.match(phone)
    if m
      @cellphone = "+1#{m[2]}#{m[3]}#{m[4]}"
    else
      @cellphone = phone
    end
    self[:cellphone] = @cellphone if self[:cellphone] != @cellphone
  end
  
  #rename dob to birthday, min_x to x_min, filter_x to x_filter
  def age
    if self.dob
      # http://stackoverflow.com/questions/819263/get-persons-age-in-ruby
      age = Date.today.year - dob.year
      age -= 1 if Date.today < dob + age.years #for days before birthday
      age # return
    end
  end
  
  def age=(age)
    if (age.length > 0)
      year = Date.today.year - age.to_i
      self.dob = Date.new(year) # assumes DOB to be January 1st
    end
  end
  
  def name
    first_name
  end
  
  def full_name
    # first + last
  end
  
  # temporary methods
  def time_to_respond
    case self.id
    when 4
      return '2 hours'
    when 9
      return '1 day'
    when 10
      return '30 minutes'
    end
  end
  
  def punctuality
    case self.id
    when 4
      return 'Always on-time'
    when 9
      return 'On-time, tends to cancel last minute'
    when 10
      return '5 minutes late on average'
    end
  end
  
  def picture_score
    case self.id
    when 4
      1.9
    when 9
      -0.5
    when 10
      0.2
    else
      0.5
    end
  end
  
  def affinity_with(user)
    # temporary
    # case user.id
    # when 2
    #   0.82
    # when 9
    #   0.82
    # when 11
    #   0.76
    # when 10
    #   0.55
    # else
    #   0.5
    # end
    0.5
  end
  
  def reputation
    #rgb(255, 0, 0)
    #rgb(255, 255, 0)
    #rgb(0, 255, 0)
    # temporary
    # goes from 0 to 511
    # case self.id
    # when 2
    #   450
    # when 9
    #   500
    # when 11
    #   150
    # when 10
    #   350
    # else
    #   511
    # end
    511
  end
  
  def tasks_count
    self.sortie_tasks_count
  end
  
  def sortie_tasks_count
    c = 0
    (self.open_sorties + self.past_sorties).each do |s|
      c += 1 if s.has_tasks_for?(self) # for double sorties, will be has_tasks_for?(user)
    end
    c
  end
  
  def friend_tasks_count
    0
  end
  
  def entered_sorties
    Sortie.entered_sorties_for(self)
  end
  
  def open_sorties
    Sortie.open_sorties_for(self)
  end
  
  def upcoming_sorties
    Sortie.upcoming_sorties_for(self)
  end
  
  def past_sorties
    Sortie.past_sorties_for(self)
  end
  
  def clear_password!
    self.password, self.password_confirmation = nil, nil
  end
  
  def foodia_profile    
    
    if (self.show_foodia)
      self.foodia_data
    else
      false
    end
    
  end
  def foodia_data
    
    r = Rails.cache.fetch("foodia/#{self.email}", :expires_in => 12.days) do
      HTTParty.get("http://foodia.com/api/partner_profile/#{email}").response
    end
  
    if (r.code == '200')
      ActiveSupport::JSON.decode(r.body)
    else
      false
    end
    
  end
  def clear_foodia
    Rails.cache.delete("foodia/#{self.email}")
  end
  
private

  

  def set_invitations_left
    self.invitations_left = 10
  end
  
  def generate_password
    # need to be upgraded when adding invitation instances
    if !self.password or self.password == ''
      # not so secure or reliable, at least should be generated locally
      self.generated_password = HTTParty.get("http://www.dinopass.com/password/simple").response.body
      self.password, self.password_confirmation = generated_password, generated_password
    end
  end
  
  
  # TODO: move to HTTParty class
  # TODO: set through event observer
  def update_email_in_list
    if email_changed?
      auth = {:username => SETTINGS[Rails.env]['CampaignMonitor']['APIKey'], :password => nil}
      q = {
        "EmailAddress" => self.email,
        "Name"         => self.name }
      r = HTTParty.put("http://api.createsend.com/api/v3/subscribers/#{SETTINGS[Rails.env]['CampaignMonitor']['UserListID']}.json", 
        basic_auth: auth,
        query: { email: self.email_was },
        body: ActiveSupport::JSON.encode(q) )
    end
  end
  
  def add_email_to_list
    # http://www.campaignmonitor.com/api/subscribers/#adding_a_subscriber
    auth = {:username => SETTINGS[Rails.env]['CampaignMonitor']['APIKey'], :password => nil}
    q = {
      "EmailAddress" => self.email,
      "Name"         => self.name,
      "Resubscribe"  => true }
    HTTParty.post("http://api.createsend.com/api/v3/subscribers/#{SETTINGS[Rails.env]['CampaignMonitor']['UserListID']}.json",
      basic_auth: auth,
      body: ActiveSupport::JSON.encode(q) )
  end
  
end

# TODO: move to Lib class file
class Height
  
  attr_reader :height
  
  IN_TO_MM = 25.4
  FT_TO_MM = 12 * IN_TO_MM
  
  # will reveive {:feet, :inches} from Controller
  def self.create(hash)
    feet   = hash[:feet].to_i
    inches = hash[:inches].to_i

    if (feet != 0 or inches != 0)
      self.new (feet * FT_TO_MM + inches * IN_TO_MM).round
    else
      self.new nil # self.new shouldn't be required, :allow_nil is behaving unexpectedly
    end
  end
  
  # will receive height from Model
  def initialize(height)
      @height = height
  end
  
  def get_ft
    @height.nil? ? nil : (to_in / 12).floor
  end
  
  def get_in
    @height.nil? ? nil : to_in % 12
  end
  
private
  def to_in
    (@height / IN_TO_MM).round
  end
end
