class EntriesController < ApplicationController
  
  before_filter :require_user
  layout "userhome"
  
  def waitlist
    
    # todo: test for non-existent sortie/not allowed
    # lookup if host has any spots left
    @sortie = Sortie.find(params[:id])
    # sort FIFO-style
    @entry = Entry.get_waitlist(@sortie)
    @left_on_list = Entry.count_left_on_list(@sortie)
    
    render :layout => 'entries'
  end
  
  def confirmation
    # fill-up details
    @sortie = Sortie.find(params[:id])
  end
  
  def invite
    # call invite method on entries or sortie model
    entry = Entry.find(params[:entry])
    
    # call model method
    entry.invite(current_user) # host: current_user
    
    # done => Done!, redirect to confirmation page
    respond_to do |format|
      format.html { redirect_to :action => :confirmation }
      format.json {
        render :json => {
          :message => 'done', # any of error, done
          :redirect_path => url_for(:controller => :sorties, :action => :confirmation, :id => entry.sortie.id) # fix
        }
      }
    end
  end
  
  def pass
    # call invite method on entries or sortie model
    entry = Entry.find(params[:entry])
    sortie = entry.sortie
    
    # call model method
    entry.pass
    
    # removed => new_list
    respond_to do |format|
      format.html { redirect_to :action => :waitlist, :id => sortie.id }
      format.json {
        
        # FIX REDUNDANCY
        # todo: test for non-existent sortie/not allowed
        # lookup if host has any spots left
        @sortie = sortie
        # sort FIFO-style
        @entry = Entry.get_waitlist(@sortie)
        @left_on_list = Entry.count_left_on_list(@sortie)
        
        with_format('html') do
          render :json => {
            :message => 'removed', # any of error, removed
            :new_list => render_to_string(:action => :waitlist, :id => sortie.id, :layout => false)
          }
        end
      }
    end
  end
  
end
