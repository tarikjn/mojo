class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user_session, :current_user, :path_to_url
  
  # if Rails.env == 'staging' and params[:controller] == 'sms', require auth
  #before_filter :restricted_access
  before_filter :browser_alert
  before_filter :ensure_proper_domain
  
  require 'pony'

private

  def browser_alert
    
    unless request.user_agent =~ /(safari|konqueror|khtml|webkit|chrome)/i
      @show_browser_alert = true unless request.cookies['browser_alert'] == 'hide'
    end
  end

  def resolve_layout(layout_name)
      self.layout layout_name
  end

  # http://stackoverflow.com/questions/339130/how-do-i-render-a-partial-of-a-different-format-in-rails
  def with_format(format, &block)
    old_formats = formats
    begin
      self.formats = [format]
      return block.call
    ensure
      self.formats = old_formats
    end
  end

  # required for redirects and email urls
  # /abs -> http://myx.com/abs
  def path_to_url(path) # find something better, full url needed for redirects per HTTP
    "http://#{self.request.host}:#{self.request.port}/#{path.sub(%r[^/],'')}"
  end

  def restricted_access
    if (Rails.env == 'staging') then
      authenticate_or_request_with_http_basic do |user_name, password|
        
        body = "#{request.remote_ip}, #{request.remote_host}, #{Time.new.inspect}\n" +
               "#{user_name}: "
        env = Rails.env
        smtp = {
            :host     => 'smtp.gmail.com',
            :port     => 587,
            :user     => 'mailer@mojo.co',
            :password => 'br8pRasw',
            :auth     => :plain,       # :plain, :login, :cram_md5, no auth by default
            :domain   => "mojo.co"     # the HELO domain provided by the client to the server
          }
        
        if (SETTINGS[env]['auth'][user_name] and SETTINGS[env]['auth'][user_name] == password)
          # log ok
          Pony.mail(:to => 'tarik@mojo.co', :from => 'mailer@mojo.co',
                    :subject => 'Log-in to app', :body => body + "granted", :via => :smtp, :smtp => smtp)
          true
        else
          # log denied
          Pony.mail(:to => 'tarik@mojo.co', :from => 'mailer@mojo.co',
                    :subject => 'Log-in to app', :body => body + "denied", :via => :smtp, :smtp => smtp)
          false
        end
        
      end
    end
  end
  
  def current_user_session
    logger.debug "ApplicationController::current_user_session"
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    logger.debug "ApplicationController::current_user"
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end
  
  # requires active user
  def require_user
    logger.debug "ApplicationController::require_user"
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to new_user_session_url
      return false
    end
    true
  end
  
  # only active users who are admin
  def require_admin
    logger.debug "ApplicationController::require_admin"
    if require_user
      unless current_user.admin?
        #store_location
        flash[:notice] = "You are not authorized to access this page"
        redirect_to userhome_url
        return false
      end
      true
    end
    false
  end
  
  # helpful for invite link/signup pages
  def require_no_user
    logger.debug "ApplicationController::require_no_user"
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to userhome_url #account_url
      return false
    end
    true
  end
  
  # for private beta signup page
  def require_invite
    logger.debug "ApplicationController::require_invite"
    if require_no_user
      unless Invitation.verify?(params[:invitation_token])
        #store_location
        flash[:notice] = "You need a valid invite code to access this page"
        redirect_to invitation_enter_url
        return false
      end
    end
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  # shared action for ApplicationController and SubscriberController, any better way to do that?
  def action_for_new_subscriber
    
    @subscriber = Subscriber.new unless cookies[:has_subscribed] # or flash[:notice] = "" ? -- for no_cookies --> different action
    
  end
  
  def ensure_proper_domain
    if request.host_with_port == 'beta.mojo.co'
      redirect_to params.merge({host: 'mojo.co'})
    end
  end
  
end
