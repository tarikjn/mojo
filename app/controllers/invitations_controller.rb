class InvitationsController < ApplicationController
  
  before_filter :require_admin, :only => [:new, :create]
  before_filter :require_no_user, :only => [:enter, :find]
  
  def new
    @invitation = Invitation.new
    render :layout => 'userhome'
  end
  
  def create
    @invitation = Invitation.new(params[:invitation])
    @invitation.source = current_user
    if @invitation.save
      Notifier.invitation(@invitation, account_signup_url(@invitation.token)).deliver
      flash[:notice] = "Thank you, invitation sent."
      redirect_to new_invitation_url
    else
      render :action => :new, :layout => 'userhome'
    end
  end

  def enter
    # token not given by route (TODO fix)
    @invitation = Invitation.new(:token => params[:invitation_token])
  end
  
  def find
    @invitation = Invitation.new(params[:invitation])
    if @invitation.valid_token?
      #flash[:notice] = "Your invite code is valid, Welcome!"
      #redirect_back_or_default account_signup_url(@invitation.token)
      redirect_to account_signup_url(@invitation.token)
    else
      render :action => :enter
    end
  end
  
end
