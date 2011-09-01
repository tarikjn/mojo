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
    @user.state = 'active'
    # TODO: load gender/preference if invitation source = Friendship
    render :layout => 'application'
  end
  
  def create
    
    # works by either create (normal signup/raw invitation) or update (invitation with request(s))
    if @user = User.unregistered.find_by_email(params[:user][:email].downcase)
      @user.attributes = params[:user]
    else
      @user = User.new(params[:user])
    end
    
    # this needs to be passed to the object instance to allow auto password-generation
    @user.require_password = false if @user.password.blank? and @user.password_confirmation.blank?
    
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
