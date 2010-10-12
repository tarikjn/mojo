class User < ActiveRecord::Base
  
  # height is in milimeters
  
  has_and_belongs_to_many :buddies, :class_name => "User", :join_table => "users_buddies",
    :foreign_key => "user_id",
    :association_foreign_key => "buddy_id"
  
end
