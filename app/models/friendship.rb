class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => "User", :foreign_key => "friend_id"
  
  has_one :invitation, :as => :source
  
  accepts_nested_attributes_for :friend
  validates_associated :friend, :invitation, :on => :create
  
  # validate that a user is already your friend?
  validates :state, :inclusion => { :in => %w(pending withdrawn approved ignored removed) }
  validate :validate_non_existing
  
  before_create :create_invitation
  
  # static
  def self.is_active_friendship?(user, friend)
    Friendship.where("((user_id = :user AND friend_id = :friend) OR (user_id = :friend AND friend_id = :user)) AND state IN (:state)", {:user => user.id, :friend => friend.id, :state => %w(pending accepted)}).count > 0
  end
  
  def self.withdraw(user, friend)
    if friendship = Friendship.where(:user_id => user.id, :friend_id => friend.id, :state => 'pending').first
      friendship.state = 'withdrawn'
      friendship.save
    else
      false
    end
  end
  
  def self.approve(user, friend)
    # user/friend order is reversed
    if friendship = Friendship.where(:user_id => friend.id, :friend_id => user.id, :state => 'pending').first
      friendship.state = 'approved'
      friendship.save
    else
      false
    end
  end
  
  def self.ignore(user, friend)
    # user/friend order is reversed
    if friendship = Friendship.where(:user_id => 2, :friend_id => 15, :state => 'pending').first
      friendship.state = 'ignored'
      friendship.save
    else
      false
    end
  end
  
  def self.delete(user, friend)
    # user/friend order works both ways
    if friendship = Friendship.where("((user_id = :user AND friend_id = :friend) OR (user_id = :friend AND friend_id = :user)) AND state = :state", {:user => user.id, :friend => friend.id, :state => 'accepted'}).first
      friendship.state = 'deleted'
      friendship.save
    else
      false
    end
  end
  
  def active?
     %w(pending accepted).include?(state)
  end
  
private
  
  def validate_non_existing
    if new_record?
      errors.add :dob, "you already have a friend request or are already friend with this user" if Friendship.is_active_friendship?(self.user, self.friend)
    end
  end
  
  def create_invitation
    
    if !self.friend.registered?
      invite = Invitation.new(:recipient_email => self.friend.email)
      invite.source = self # the Friendship object
      self.invitation = invite
    end
    
  end
  
end
