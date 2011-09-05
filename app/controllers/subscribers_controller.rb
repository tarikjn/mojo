class SubscribersController < ApplicationController
  
  # GET /subscribe
  def new
    # check cookie / create new object
    action_for_new_subscriber
    
    render :layout => !request.xhr?
  end

  # POST /subscribe
  def create
    @subscriber = Subscriber.new(params[:subscriber])
    
    # set IP, request is only available in controller...
    @subscriber.remote_addr = request.remote_ip

    if @subscriber.save
      # show thank you once
      flash[:notice] = "Thank you!"
      
      # make share actions stiky
      cookies[:has_subscribed] = { :value => 'true', :expires => Time.now + 30.days}
      
      # send email asynchro
      Notifier.delay.welcome_subscriber(@subscriber.email)
      
      # redirect (ajax or not)
      redirect_to new_subscriber_url # or root_url (is non-xhr)
    else
      render action: 'new',  layout: !request.xhr?
    end
  end
  
end
