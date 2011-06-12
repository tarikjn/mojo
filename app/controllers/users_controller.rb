class UsersController < ApplicationController
  # GET /users/1/edit
  
  before_filter :require_user, :except => [:signup, :create]
  before_filter :require_invite, :only => [:signup, :create]
  helper_method :account_section
  layout 'userhome'
  
  def index
    redirect_to :userhome
  end
  
  def signup
    # TODO find user(state=invitation) using email (friend/date invite was done)
    @user = User.new(:invitation_token => params[:invitation_token])
    @user.email = @user.invitation.recipient_email if @user.invitation
    render :layout => 'application'
  end
  
  def create
    @user = User.new(params[:user])
    
    if @user.save
      flash[:notice] = "Welcome!"
      Notifier.welcome(@user).deliver
      redirect_to root_url
    else
      @user.clear_password! if @user.generated_password
      render :action => :signup, :layout => 'application'
    end
  end
  
  def edit
    @user = current_user
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = current_user

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = "Changes saved."
        format.html { redirect_to account_edit_url(account_section) }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # account
  # def profile
  #     @user = current_user
  #   end
  #   
  #   # picture (profile)
  #   def picture
  #     @user = current_user
  #   end
  #   
  #   # filters
  #   def filters
  #     @user = current_user
  #   end
  #   
  #   # access
  #   def password
  #     @user = current_user
  #   end
  
  # (notifications)
  
  # (payment)
private

  def account_section
    params[:account_section]
  end
  
end
