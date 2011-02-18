class UserhomeController < ApplicationController
  
  before_filter :require_user
  
  def index
    @user = current_user
    @buddies = current_user.buddies
  end

  def dates
  end
  
  def settings
  end

end
