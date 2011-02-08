class WaitlistEntry < ActiveRecord::Base
  belongs_to :user
  belongs_to :activity
  
  validates_inclusion_of :state, :in => %w(waiting invited ejected)
  
  def self.get_waitlist(activity) # rename to find, unless count is included
    where(:activity_id => activity.id, :state => 'waiting').first
    # Item.all(:conditions => ['tags.id in (?)', tag_ids], :joins => :tags)
  end
  
  def self.count_left_on_list(activity)
    (where(:activity_id => activity.id, :state => 'waiting').count) - 1
  end
  
  def invite(host)
    # find wether current user is creator or his/her invitee (friend)
    # participant is self.user
    # host is current_user
    activity = self.activity
    
    case host
    when activity.creator
      duo = :creator_duo
    when activity.guest
      duo = :invitee_duo
    end
    
    # add participant to Duo
    activity.creator_duo.assign(self.user)
    activity.update_state() # fix for duo.activity not referenced correctly, fix model relationship
    
    # change state of entry
    self.state = 'invited'
    
    # commit
    self.save
  end
  
  # eject entry
  def pass
    # send a notification?
    # might want to use activity/duo model to send notification to co-host
    
    # change state of entry
    self.state = 'ejected'
    
    #commit
    self.save
  end
end
