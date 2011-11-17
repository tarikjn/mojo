class HomepageController < ApplicationController
  
  skip_before_filter :browser_alert
  
  def index
    
    # set up flikr photostream
    # START
    # flikr_p = {
    #       id: '63607700@N03',
    #       format: 'json'
    #     }.to_params
    #     
    #     r = Rails.cache.fetch("flikr/photostream", :expires_in => 12.days) do
    #       HTTParty.get("http://api.flickr.com/services/feeds/photos_public.gne?#{flikr_p}").response
    #     end
    #   
    #     # removes "jsonFlickrFeed(--)"
    #     flikr_body = r.body[15, -1]
    #     @photostream = (r.code == '200')? ActiveSupport::JSON.decode(flikr_body) : false
    # END
    
    if current_user
      render layout: 'landing'
    else
      # check cookie / create new object
      action_for_new_subscriber
      render 'subscribers/new', layout: 'subscribers'
    end
  end
  
  def team
  end

end
