class FollowsController < ApplicationController

  before_filter :require_user

  # TODO: DRY-up code repetition
  def create
    @user = User.find(params[:user_id])
    current_user.follow!(@user)
    
    respond_to do |format|
      format.html { redirect_to userhome_url, notice: "Your are now following #{@user.name}." } #@user
      format.js   { render partial: 'button', locals: {user: @user} }
    end
  end

  def destroy
    @user = User.find(params[:user_id])
    current_user.unfollow!(@user)
    
    respond_to do |format|
      format.html { redirect_to userhome_url, notice: "Your are no more following #{@user.name}." } #@user
      format.js   { render partial: 'button', locals: {user: @user} }
    end
  end

end
