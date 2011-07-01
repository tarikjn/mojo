class Wing < ActiveRecord::Base
  belongs_to :lead, :class_name => "User"
  belongs_to :mate, :class_name => "User"
  
  # either
  has_one :entry, :as => :party, :dependent => :destroy
  # or
  has_one :sortie, :as => :party, :dependent => :destroy
  
  def self.with(user)
    self.find(:all, :conditions => ["lead_id = ? OR mate_id = ?", user.id, user.id])
  end
  
  def self.ids_with(user)
    self.with(user).map {|x| x.id}
  end
  
  def individuals
    [lead, mate]
  end
end
