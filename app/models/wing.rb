class Wing < ActiveRecord::Base
  belongs_to :lead, :class_name => "User"
  belongs_to :mate, :class_name => "User"
  
  # either
  has_one :host_sortie, :class_name => "Sortie", :as => :host #, :dependent => :destroy
  # or
  has_one :guest_sortie, :class_name => "Sortie", :as => :guest #, :dependent => :destroy
  # or should it be :as => :wing, :foreign_key => "host_id"??/same for guest
  
  # or/and (can both have a guest_sortie and entry)
  has_one :entry, :as => :party #, :dependent => :destroy
  
  before_destroy :is_orphan?
  
  def is_orphan?
    self.host_sortie.nil? and self.guest_sortie.nil? and self.entry.nil?
  end
  
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
