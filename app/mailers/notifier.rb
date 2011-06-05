class Notifier < ActionMailer::Base
  #include ApplicationController
  #helper :path_to_url
  
  default :from => "mailer@mojo.co"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.new_entrant.subject
  #
  def new_entrant(sortie, host) # double-dates: send 2 emails from here or iterate in model?
    @greeting = "Hi"
    
    # temporary fix here
    @action_path = path_to_url "/entries/#{sortie.id}"
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
    @confirmation_url = path_to_url "/dates/#{sortie.id}"
  end
  
  # duplicated for mailer, find other way...
  # required for redirects and email urls
  # /abs -> http://myx.com/abs
  def path_to_url(path) # find something better, full url needed for redirects per HTTP
    "http://staging.mojo.co"
  end
  
  def password_reset_instructions(user, reset_url)  
    subject       "Password Reset Instructions"
    recipients    user.email
    body          :edit_password_reset_url => reset_url
end
