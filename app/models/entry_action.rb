class EntryAction < ActiveRecord::Base
  belongs_to :entry
  belongs_to :by, :class_name => "User"
  
  validates :action, :inclusion => { :in => %w(approve withdraw reject) }
end
