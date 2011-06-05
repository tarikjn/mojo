class Wing < ActiveRecord::Base
  belongs_to :lead, :class_name => "User"
  belongs_to :mate, :class_name => "User"
  
  # either
  has_one :entry, :as => :party, :dependent => :destroy
  # or
  has_one :sortie, :as => :party, :dependent => :destroy
end
