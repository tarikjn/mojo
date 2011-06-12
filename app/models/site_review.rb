class SiteReview < ActiveRecord::Base
  belongs_to :by, :class_name => "User"
  belongs_to :sortie
end
