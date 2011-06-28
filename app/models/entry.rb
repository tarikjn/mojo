class Entry < ActiveRecord::Base
  belongs_to :party, :polymorphic => true
  belongs_to :sortie
  has_many :entry_actions, :dependent => :destroy
  
  # overridden happens when joining multiple dates happening at close times and the user is selected in one
  validates_inclusion_of :state, :in => %w(waiting invited rejected withdrawn overridden) # renamed ejected to rejected
  
  # scopes
  scope :waiting, :conditions => ["state = ?", 'waiting']
  scope :nearby, lambda { |time|
    {
      :include => :sortie,
      :conditions => ['sorties.state = :state AND sorties.time > :start AND sorties.time < :end',
        {:state => 'open', :start => time - 2.hour, :end => time + 1.hour}]
    }
  }
  
  def self.get_waitlist(sortie) # rename to find, unless count is included
    where(:sortie_id => sortie.id, :state => 'waiting').first
    # Item.all(:conditions => ['tags.id in (?)', tag_ids], :joins => :tags)
  end
  
  def self.count_left_on_list(sortie)
    (where(:sortie_id => sortie.id, :state => 'waiting').count) - 1
  end
  
  # should be renamed to invite_by
  def invite(host)
    
    if self.state == 'waiting'
      # record entry_action
      self.entry_actions << EntryAction.new(:by => host, :action => 'approve')
    
      # add participant to sortie
      self.sortie.guest = self.party
    
      # add participant to sortie
      self.sortie.update_state()
    
      # change state of entry
      self.state = 'invited'
    
      # commit
      self.save
      
      # override concurrent entries
      self.override_concurrents
    else
      false
    end
    
  end
  
  # eject entry
  def pass
    # send notification to host's mate/lead to look at next entrant, if any
    
    # change state of entry
    self.state = 'rejected'
    
    # commit
    self.save
  end

  def override_concurrents
    
    # find all entries for that party in nearby time
    concurrents = Entry.where(:party_id => self.party, :party_type => 'User').where('entries.state = ? AND entries.id != ?', 'waiting', self.id).nearby(self.sortie.time)
    
    # set all the waiting ones to overriden
    #concurrents.update_all(:state => 'overridden') broken with nearby's query
    concurrents.each { |c|
      c.state = 'overridden'
      c.save
    }
    
  end
  
end
