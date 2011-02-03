class User < ActiveRecord::Base
  has_many :activities, :through => :waitlist_entries, :as => :joined_dates
  
  # AuthLogic
  acts_as_authentic
  
  validates_uniqueness_of :email
  validates_presence_of :email, :first_name
  validates_inclusion_of :sex, :in => %w(male female)  
  # height is in milimeters
  
  has_and_belongs_to_many :buddies, :class_name => "User", :join_table => "users_buddies",
    :foreign_key => "user_id",
    :association_foreign_key => "buddy_id"
  
  def age
    # not very good, not all years have 365 days, age may be wrong on/around birthday
    ((Date.today - self.dob) / 365).to_i
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
      return 1.9
    when 9
      return -0.5
    when 10
      return 0.2
    end
  end
  
  def afinity_with(user)
    # temporary
    if user.id == 1
      case self.id
      when 4
        return 0.82
      when 9
        return 0.76
      when 10
        return 0.55
      end
    end
  end
  
end
