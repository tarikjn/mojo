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
    @waitlist = sortie.entries
    
    
    # add conditional formating: first user or other user waiting
    mail :to => host.email
  end
  
  def invited_confirmation(sortie, guest)
    @greeting = "Hi"
    
    @guest = guest
    @sortie = sortie
    # temporary fix here
    @confirmation_url = confirmation_date_url(sortie)
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
end
