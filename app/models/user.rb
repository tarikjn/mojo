class User < ActiveRecord::Base
  
  validates_uniqueness_of :email
  validates_presence_of :email, :first_name
  validates_inclusion_of :sex, :in => %w(male female)  
  # height is in milimeters
  
  has_and_belongs_to_many :buddies, :class_name => "User", :join_table => "users_buddies",
    :foreign_key => "user_id",
    :association_foreign_key => "buddy_id"
  
  def age
    # not very good, not all years have 365 days, age may be wrong on/around birthday
    (Date.today - self.dob) / 365
  end
  
end
