class Entry < ActiveRecord::Base
  belongs_to :party, :polymorphic => true
  belongs_to :sortie
  has_many :entry_actions, :dependent => :destroy
  
  validates_inclusion_of :state, :in => %w(waiting invited rejected withdrawn overridden) # renamed ejected to rejected
  
  def self.get_waitlist(sortie) # rename to find, unless count is included
    where(:sortie_id => sortie.id, :state => 'waiting').first
    # Item.all(:conditions => ['tags.id in (?)', tag_ids], :joins => :tags)
  end
  
  def self.count_left_on_list(sortie)
    (where(:sortie_id => sortie.id, :state => 'waiting').count) - 1
  end
  
  def invite(host)
    # find wether current user is creator or his/her invitee (friend)
    # participant is self.user
    # host is current_user
    sortie = self.sortie
    
    case host
    when sortie.creator
      duo = :creator_duo
    when false #sortie.guest
      duo = :invitee_duo
    end
    
    # add participant to Duo
    #sortie.creator_duo.assign(self.user) REFACTOR
    sortie.update_state() # fix for duo.sortie not referenced correctly, fix model relationship
    
    # change state of entry
    self.state = 'invited'
    
    # commit
    self.save
  end
  
  # eject entry
  def pass
    # send a notification?
    # might want to use sortie/duo model to send notification to co-host
    
    # change state of entry
    self.state = 'rejected'
    
    #commit
    self.save
  end
end
