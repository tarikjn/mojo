class User < ActiveRecord::Base
  include ActiveModelExtensions # Mojo's
  
  has_many :activities, :through => :waitlist_entries, :as => :joined_dates
  
  # AuthLogic
  acts_as_authentic do |config|
    config.validate_email_field = false
    config.ignore_blank_passwords = true # not working?
    # hack
    config.validate_password_field = false
    config.require_password_confirmation = false
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
  
  # discovery is never saved (no email)
  validates :completeness, :inclusion => { :in => %w(discovery invitation complete) }
  validates :email, :presence => true, :uniqueness => true, :email => true, :unless => :is_discovery
  validates :first_name, :presence => true, :if => :is_complete
  # picture fails with marshaling
  #validates :picture, :presence => true, :if => :is_complete
  validates :cellphone, :presence => true, :if => :is_complete
  validates :sex, :inclusion => { :in => %w(male female), :message => "Please select" }
  validates :sex_preference, :inclusion => { :in => %w(female both male), :message => "Please select" }
  # height is in milimeters
  
  has_and_belongs_to_many :buddies, :class_name => "User", :join_table => "users_buddies",
    :foreign_key => "user_id",
    :association_foreign_key => "buddy_id"
  
  # overrides access to db height attribute
  composed_of :height, :class_name => 'Height', :mapping => %w(height height),
              :allow_nil => true, :converter => Proc.new { |hash| Height.create(hash) }
  composed_of :min_height, :class_name => 'Height', :mapping => %w(height_min height),
               :allow_nil => true, :converter => Proc.new { |hash| Height.create(hash) }
  composed_of :max_height, :class_name => 'Height', :mapping => %w(height_max height),
              :allow_nil => true, :converter => Proc.new { |hash| Height.create(hash) }
  # any way to DRY up code above and below?
  def is_discovery
    (self.completeness == 'discovery')
  end
  
  def is_invitation
    (self.completeness == 'invitation')
  end
  
  def is_complete
    (self.completeness == 'complete')
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
  
  def open_activities
    Activity.open_activities_for(self)
  end
  
  def upcoming_dates
    Activity.upcoming_activities_for(self)
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
