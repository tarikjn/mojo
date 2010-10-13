class Duo < ActiveRecord::Base
  has_one :activity
  belongs_to :host, :class_name => "User"
  belongs_to :participant, :class_name => "User"
end
