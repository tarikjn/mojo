class UserRating < ActiveRecord::Base
  belongs_to :user
  belongs_to :by, :class_name => "User"
  belongs_to :sortie
end
