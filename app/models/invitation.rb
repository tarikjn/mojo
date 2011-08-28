class Invitation < ActiveRecord::Base
  belongs_to :source, :polymorphic => true # User or Friendship
  has_one :recipient, :class_name => 'User'
  
  validates :recipient_email, :presence => true
  validates :token, :uniqueness => true # TODO: auto-regenerate if exists...
  validate :recipient_is_not_registered
  validate :sender_has_invitations, :if => :sender
  
  before_create :generate_token
  before_create :decrement_sender_count, :if => :sender
  
  # not the DRYiest thing because validation is also done in find action
  def self.verify?(token)
    # check if the invitation exists
    invite = Invitation.find_by_token(token)
    if invite
      # and it's not associated to any registred user
      if User.registered.find_by_invitation_id(invite)
        false
      else
        true
      end
    else
      false
    end
  end
  
  # used by the "Enter your invite form", must be a better way to do that
  def valid_token?
    # we check against a copy invitation object
    match = Invitation.find_by_token(token)
    
    if !match
      errors.add :token, 'not found'
      return false
    elsif User.registered.find_by_invitation_id(match)
      errors.add :token, 'already used'
      return false
    end
    
    true
  end
  
  def sender
    self.source.is_a?(User) ? self.source : self.source.user
  end
  
  def recipient_email=(umail) 
    write_attribute(:recipient_email, umail.downcase) 
  end
  
private
  
  def recipient_is_not_registered
    errors.add :recipient_email, 'is already registered' if User.registered.find_by_email(recipient_email)
  end

  def sender_has_invitations
    unless sender.invitations_left.nil? or sender.invitations_left > 0
      errors.add :base, 'You have reached your limit of invitations to send.'
    end
  end

  def generate_token
    self.token = ActiveSupport::SecureRandom.hex(4)
  end

  def decrement_sender_count
    sender.decrement! :invitations_left unless sender.invitations_left.nil?
  end
end
