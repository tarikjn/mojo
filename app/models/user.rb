class User < ActiveRecord::Base
  include ActiveModelExtensions # Mojo's
  
  #attr_accessible :first_name, :last_name, :email, :invitation_token, :dob, :picture, :cellphone
  
  # not so secure but practical
  before_validation :generate_password! # has some issue: password is reprinted and not mailed on failed validation
  before_create :set_invitations_left
  attr_accessor :generated_password, :current_password
  #attr_writer :current_password
  
  has_many :entries, :as => :party
  has_many :entered_sorties, :through => :entries, :source => :sortie, :as => :party
  
  # problem: how to do hosted_sorties both for single sorties and through wings
  
  #has_many :hosted_single_sorties, :source => :sortie, :as => :host
  #has_many :invited_single_sorties, :source => :sortie, :as => :guest
  
  # reports made by the user
  has_many :authored_reports, :class_name => "SortieReport", :foreign_key => "by_id"
  # these are reports where the user is tagged as "culprit"
  has_and_belongs_to_many :received_reports, :class_name => "SortieReport", :join_table => "sortie_reports_culprits"
  
  has_many :picture_ratings#, :conditions => ["picture_file_name = ?", self.picture]
  has_many :ratings, :class_name => "UserRating"
  
  has_many :hosted_sorties, :class_name => "Sortie", :as => :host
  
  # AuthLogic
  acts_as_authentic do |config|
    config.validate_email_field = false
    config.ignore_blank_passwords = false
    # hack
    #config.validate_password_field = false
    #config.require_password_confirmation = false
  end
  
  # avatar/s3, TODO: switch to CarrierWave, Paperclip is retarded
  #attr_accessible :avatar, :age, :filter_age, :filter_height, :first_name, :last_name, :email, :cellphone, :sex, :sex_preference, :dob, :min_age, :max_age, :height, :min_height, :max_height
  #has_attached_file :avatar, :styles => { :thumb => "96x96#", :mini => "48x48#" },
  #  :storage => :s3,
  #  :s3_credentials => SETTINGS[Rails.env]['s3'],
  #  :path => ":class/:attachment/:id/:style.:extension",
  #  :bucket => SETTINGS[Rails.env]['bucket']
  #attr_accessible :picture
  mount_uploader :picture, PictureUploader
  
  # add state machine for stepflow/discovery state (object not saved)
  validates :state, :inclusion => { :in => %w(invitation active blocked) }
  validates :level, :inclusion => { :in => %w(user admin) }
  validates :email, :presence => true, :uniqueness => true, :email => true
  validates :first_name, :presence => true, :if => :active?
  validate :validate_age
  validate :validate_current_password
  # picture fails with marshaling (stepflow issue)
  validates :picture, :presence => true, :if => :active?
  validates :cellphone, :presence => true, :if => :active?
  validates :sex, :inclusion => { :in => %w(male female), :message => "Please select" }
  validates :sex_preference, :inclusion => { :in => %w(female both male), :message => "Please select" }
  # height is in milimeters
  
  # overrides access to db height attribute
  composed_of :height, :class_name => 'Height', :mapping => %w(height height),
              :allow_nil => true, :converter => Proc.new { |hash| Height.create(hash) }
  composed_of :min_height, :class_name => 'Height', :mapping => %w(height_min height),
               :allow_nil => true, :converter => Proc.new { |hash| Height.create(hash) }
  composed_of :max_height, :class_name => 'Height', :mapping => %w(height_max height),
              :allow_nil => true, :converter => Proc.new { |hash| Height.create(hash) }
  
  # friendship TODO: add :dependant => :destroy?         
  has_many :friendships
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :direct_friends, :through => :friendships, :conditions => ["approved = ?", true], :source => :friend
  has_many :inverse_friends, :through => :inverse_friendships, :conditions => ["approved = ?", true], :source => :user

  has_many :pending_friends, :through => :friendships, :conditions => ["approved = ?", false], :foreign_key => "user_id", :source => :user
  has_many :requested_friendships, :class_name => "Friendship", :foreign_key => "friend_id", :conditions => ["approved = ?", false]
  
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

  def friends
    direct_friends | inverse_friends
  end
  
  # TODO: secure active and admin attributes with attr_accessible?
  # Authlogic checks this
  def active?
    state == 'active'
  end
  
  def admin?
    level == 'admin'
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
  
  def validate_current_password
    return true
    errors.add :current_password, 'is incorrect' if !@current_password.nil? and @current_password != password
  end
  
  def current_password=(s)
    @current_password = s
  end
  
  def current_password
    nil
  end
  
  def possessive
    self.sex == 'male'? 'his' : 'her'
  end
  
  # for SQL scopes
  def looking_for
    sex_preference == 'both'? ['male', 'female'] : [sex_preference]
  end
  
  # TODO: find a way to remove these, the converter should make it unecessary
  def height=(hash)
    @height = Height.create(hash)
  end
  
  def min_height=(hash)
    @min_height = Height.create(hash)
  end
  
  def max_height=(hash)
    @max_height = Height.create(hash)
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
  
  def afinity_with(user)
    # temporary
    if user.id == 1
      case self.id
      when 4
        0.82
      when 9
        0.76
      when 10
        0.55
      else
        0.5
      end
    else
      0.5
    end
    
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

private

  def set_invitations_left
    self.invitations_left = 10
  end
  
  def generate_password!
    if !self.password
      @generated_password = HTTParty.get("http://www.dinopass.com/password/simple").response.body
      self.password, self.password_confirmation = @generated_password, @generated_password
    end
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
      nil
    end
  end
  
  # will receive height from Model
  def initialize(height)
      @height = height
  end
  
  def get_ft
    (to_in / 12).floor
  end
  
  def get_in
    to_in % 12
  end
  
private
  def to_in
    (@height / IN_TO_MM).round
  end
end
