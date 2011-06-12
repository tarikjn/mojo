class PlaceReview < ActiveRecord::Base
  belongs_to :place
  belongs_to :by, :class_name => "User"
  belongs_to :sortie
end
