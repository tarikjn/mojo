class UsersController < ApplicationController
  # GET /users/1/edit
  
  before_filter :require_user, :except => [:signup, :create]
  #before_filter :require_invite, :only => [:signup, :create]
  helper_method :account_section
  layout 'userhome'
  
  def index
    redirect_to :userhome
  end
  
  def signup
    
    # NOTE: assuming token is valid and required in this action
    i = Invitation.find_by_token(params[:invitation_token])
    
    # load by email associated to invitation_token (friend/date invite was sent if found)
    @user = User.new unless i and @user = User.unregistered.find_by_email(i.recipient_email)
    
    @user.invitation_token = i.token if i # or params[:invitation_token]
    @user.email = @user.invitation.recipient_email if @user.invitation and @user.new_record?
    @user.state = 'active'
    
    # if the user choose to change his acocunt email he would still keep the friend requests
    
    render :layout => 'application'
  end
  
  def create
    
    # works by either create (normal signup/raw invitation) or update (invitation with request(s))
    
    # load by ID first (may pause security issues, shoudl check it matches with original token.recipient)
    if params[:user][:id] and @user = User.unregistered.find(params[:user][:id])
      @user.attributes = params[:user]
    # try by email in case the user is signing up on his own/using a plain invite
    elsif @user = User.unregistered.find_by_email(params[:user][:email].downcase)
      @user.attributes = params[:user]
    # fresh new user, obviously
    else
      @user = User.new(params[:user])
    end
    
    # this needs to be passed to the object instance to allow auto password-generation
    @user.require_password = false if @user.password.blank? and @user.password_confirmation.blank?
    
    # upload user picture from fb for event
    #Logger.new(STDOUT).info(@user.picture_url)
    if fb_uid = User.getFacebookUIDByEmail(@user.email)
      @user.remote_picture_url = "http://graph.facebook.com/#{fb_uid}/picture?type=large" if @user.picture_url == '/assets/fallback/default.png'
    end
    
    if @user.save
      flash[:notice] = "Welcome!"
      Notifier.welcome(@user).deliver
      
      # force user autologin when password has been auto-generated
      UserSession.create(@user) if !current_user
      
      redirect_to search_dates_url #userhome_url
    else
      #@user.clear_password! if @user.generated_password
      render :action => :signup, :layout => 'application'
    end
  end
  
  def edit
    @user = current_user
  end
  
  def profile
    @user = current_user
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    # User.find(current_user) vs plain current_user avoids failed name change to appear immediately in layout
    @user = User.find(current_user.id)
    
    # this needs to be passed to the object instance so that it validates the current password
    # any more elegant way to do it?
    @user.validate_current_password = true if account_section == 'password'

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
