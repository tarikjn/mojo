class Activity < ActiveRecord::Base
  belongs_to :creator_duo, :class_name => "Duo"
  belongs_to :invitee_duo, :class_name => "Duo"
  
  # TODO: add shortcut of type activity.creator => activity.creator_duo.host
  def creator
    self.creator_duo.host
  end
  
  def invitee
    self.invitee_duo.host
  end
end
