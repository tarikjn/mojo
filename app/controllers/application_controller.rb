class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user_session, :current_user
  
  # if Rails.env == 'staging' and params[:controller] == 'sms', require auth
  before_filter :restricted_access
  
  require 'pony'

  private

  def restricted_access
    if (Rails.env == 'staging') then
      authenticate_or_request_with_http_basic do |user_name, password|
        
        body = "#{request.remote_ip}, #{request.remote_host}, #{Time.new.inspect}\n" +
               "#{user_name}: "
        env = Rails.env
        
        if (SETTINGS[env]['auth'][user_name] and SETTINGS[env]['auth'][user_name] == password)
          # log ok
          Pony.mail(:to => 'tarik@mojo.co', :from => 'mailer@mojo.co',
                    :subject => 'Log-in to app', :body => body + "granted")
          true
        else
          # log denied
          Pony.mail(:to => 'tarik@mojo.co', :from => 'mailer@mojo.co',
                    :subject => 'Log-in to app', :body => body + "denied")
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

  def require_user
    logger.debug "ApplicationController::require_user"
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to new_user_session_url
      return false
    end
  end

  #def require_no_user
  #  logger.debug "ApplicationController::require_no_user"
  #  if current_user
  #    store_location
  #    flash[:notice] = "You must be logged out to access this page"
  #    redirect_to account_url
  #    return false
  #  end
  #end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end
