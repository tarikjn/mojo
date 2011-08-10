class Notifier < ActionMailer::Base
  #include ApplicationController
  #helper :path_to_url
  
  #include Delayed::Mailer
  
  default :from => "mailer@mojo.co", :reply_to => "support@mojo.co"

  def welcome(user)
    @user = user
    mail :to => user.email
  end
  
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.new_entrant.subject
  #
  def new_entrant(sortie, host) # double-dates: send 2 emails from here or iterate in model?
    @greeting = "Hi"
    
    # temporary fix here
    @action_path = date_entries_url(sortie.id)
    @sortie = sortie # pass as :locals?
    @host = host
    @waitlist = sortie.entries.waiting
    
    
    # add conditional formating: first user or other user waiting
    mail :to => host.email
  end
  
  def invited_confirmation(sortie, guest)
    
    @guest = guest
    @sortie = sortie
    
    @confirmation_url = confirmation_date_url(sortie)
    
    mail :to => guest.email
  end
  
  def date_canceled(sortie, actor, party)
    
    @actor = actor
    @party = party
    @sortie = sortie
    
    mail :to => party.email
  end
  
  def password_reset_instructions(user)
    @edit_password_reset_url = edit_password_reset_url(user.perishable_token)
    mail :to => user.email
  end
  
  def invitation(invitation, signup_url)
    #subject    "Invitation"
    #recipients invitation.recipient_email
    #body       :invitation => invitation, :signup_url => signup_url
    @invitation = invitation
    @signup_url = signup_url
    
    mail :to => invitation.recipient_email
    invitation.update_attribute(:sent_at, Time.now)
  end
  
  def new_date_by_followed(sortie, host, user)
    
    @sortie = sortie
    @followed = host
    @follower = user
    
    @sortie_url = search_dates_url
    @unfollow_url = destroy_user_follows_url(host)
    
    mail to: user.email, subject: "#{host.name} just created a date!"
    
  end
  
  def friend_request(friendship)
    
    @user = friendship.user
    @recipient = friendship.friend
    
    @friends_url = friendships_url
    
    mail to: @user.email, subject: "#{@user.name} sent you a wingmate request on Mojo"
    
  end
  
  def friend_invite(friendship, invitation)
    
    @user = friendship.user
    @recipient = friendship.friend
    
    @signup_url = account_signup_url(invitation.token)
    
    mail to: @user.email, subject: "#{@user.name} invited you on Mojo"
    
  end
  
  def friend_approved(user, friend)
    
    @user = user
    @friend = friend
    
    mail to: @user.email, subject: "#{@friend.name} approved your wingmate request"
    
  end
end
