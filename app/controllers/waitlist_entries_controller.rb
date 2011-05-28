class WaitlistEntriesController < ApplicationController
  
  before_filter :require_user
  layout "userhome"
  
  def waitlist
    
    # todo: test for non-existent activity/not allowed
    # lookup if host has any spots left
    @activity = Activity.find(params[:id])
    # sort FIFO-style
    @entry = WaitlistEntry.get_waitlist(@activity)
    @left_on_list = WaitlistEntry.count_left_on_list(@activity)
    
    render :layout => 'waitlist_entries'
  end
  
  def confirmation
    # fill-up details
    @activity = Activity.find(params[:id])
  end
  
  def invite
    # call invite method on entries or activity model
    entry = WaitlistEntry.find(params[:entry])
    
    # call model method
    entry.invite(current_user) # host: current_user
    
    # done => Done!, redirect to confirmation page
    respond_to do |format|
      format.html { redirect_to :action => :confirmation }
      format.json {
        render :json => {
          :message => 'done', # any of error, done
          :redirect_path => url_for(:controller => :activities, :action => :confirmation, :id => entry.activity.id) # fix
        }
      }
    end
  end
  
  def pass
    # call invite method on entries or activity model
    entry = WaitlistEntry.find(params[:entry])
    activity = entry.activity
    
    # call model method
    entry.pass
    
    # removed => new_list
    respond_to do |format|
      format.html { redirect_to :action => :waitlist, :id => activity.id }
      format.json {
        
        # FIX REDUNDANCY
        # todo: test for non-existent activity/not allowed
        # lookup if host has any spots left
        @activity = activity
        # sort FIFO-style
        @entry = WaitlistEntry.get_waitlist(@activity)
        @left_on_list = WaitlistEntry.count_left_on_list(@activity)
        
        with_format('html') do
          render :json => {
            :message => 'removed', # any of error, removed
            :new_list => render_to_string(:action => :waitlist, :id => activity.id, :layout => false)
          }
        end
      }
    end
  end
  
end
