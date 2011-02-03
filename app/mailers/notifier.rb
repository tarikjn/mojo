class Notifier < ActionMailer::Base
  default :from => "mailer@mojo.co"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.new_entrant.subject
  #
  def new_entrant(activity, host) # double-dates: send 2 emails from here or iterate in model?
    @greeting = "Hi"
    
    @action_path = "/participants/#{activity.id}"
    @activity = activity # pass as :locals?
    @host = host
    @waitlist = activity.waitlist_entries
    
    
    # add conditional formating: first user or other user waiting
    mail :to => host.email
  end
end
