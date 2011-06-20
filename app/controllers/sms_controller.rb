class SmsController < ApplicationController
  # Trails can be used to have testing (SMS simulation?)
  skip_before_filter :restricted_access
  
  def receive
    # should log messages
    # handle errrors / random requests
    caller_id = params[:From]
    body = params[:Body]
    
    # lookup sender's callerID
    sender = User.find_by_cellphone(caller_id)
    
    if (sender)
      
      # find the people on his date
      sortie = Sortie.find_active_sortie_for(sender)
      
      if (sortie)
        @recipients = [sortie.party_of(sender)]
    
        # format response
        @message = "#{sender.first_name}: #{body}"
      else
        @recipients = [sender]
        @message = "Mojo: Hey #{sender.first_name}, oops you don't have any current date at the moment..."
      end
      
    else
      
      @recipients = [User.new(:cellphone => caller_id)]
      @message = "Mojo: Sorry, we could not recognize your caller ID."
    
    end
    
    # default view send message to them
    
  end
  
end
