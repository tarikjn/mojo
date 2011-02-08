class Duo < ActiveRecord::Base
  has_one :activity # fix can't be referenced from Duo
  belongs_to :host, :class_name => "User"
  belongs_to :participant, :class_name => "User"
  
  def assign(participant)
    self.participant = participant
    
    #commit
    self.save
    
    # send notification to participant
    
    # let activity know a participant has been added
    #self.activity.update()
    # not working, it's looking for activity.duo_id = ...
  end
end
