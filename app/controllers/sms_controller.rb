class SmsController < ApplicationController
  # Trails can be used to have testing (SMS simulation?)
  
  def receive
    # should log messages
    # handle errrors / random requests
    caller_id = params[:From]
    body = params[:Body]
    
    # lookup sender's callerID
    sender = User.find_by_cellphone(caller_id)
    
    # find the people on his date
    activity = Activity.find_active_activity_for(sender)
    recipients = (activity.get_people)
    recipients.delete(sender)
    
    # format response
    @message = "#{sender.first_name}: #{body}"
    @recipients = recipients
    
    # default view send message to them
  end
end
