class HomepageController < ApplicationController
  
  skip_before_filter :browser_alert
  
  def index
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
