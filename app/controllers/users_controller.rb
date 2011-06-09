class UsersController < ApplicationController
  # GET /users/1/edit
  
  before_filter :require_user, :except => [:signup, :create]
  before_filter :require_invite, :only => [:signup, :create]
  
  def signup
    # TODO find user(state=invitation) using email (friend/date invite was done)
    @user = User.new(:invitation_token => params[:invitation_token])
    @user.email = @user.invitation.recipient_email if @user.invitation
  end
  
  def create
    @user = User.new(params[:user])
    
    if @user.save
      flash[:notice] = "Welcome!"
      Notifier.welcome(@user).deliver
      redirect_to root_url
    else
      @user.clear_password! if @user.generated_password
      render :action => :signup
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # account
  
  # picture (profile)
  
  # filters
  
  # access
  
  # (notifications)
  
  # (payment)
end
