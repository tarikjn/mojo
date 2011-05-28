class Notifier < ActionMailer::Base
  #include ApplicationController
  #helper :path_to_url
  
  default :from => "mailer@mojo.co"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.new_entrant.subject
  #
  def new_entrant(activity, host) # double-dates: send 2 emails from here or iterate in model?
    @greeting = "Hi"
    
    # temporary fix here
    @action_path = path_to_url "/entries/#{activity.id}"
    @activity = activity # pass as :locals?
    @host = host
    @waitlist = activity.waitlist_entries
    
    
    # add conditional formating: first user or other user waiting
    mail :to => host.email
  end
  
  def invited_confirmation(activity, guest)
    @greeting = "Hi"
    
    @guest = guest
    @activity = activity
    # temporary fix here
    @confirmation_url = path_to_url "/dates/#{activity.id}"
  end
  
  # duplicated for mailer, find other way...
  # required for redirects and email urls
  # /abs -> http://myx.com/abs
  def path_to_url(path) # find something better, full url needed for redirects per HTTP
    "http://staging.mojo.co"
  end
end
