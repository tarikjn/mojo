class EntriesController < ApplicationController
  
  before_filter :require_user
  layout "userhome"
  
  # date_entries_path(@sortie)
  def index
    
    # todo: test for non-existent sortie/not allowed
    # lookup if host has any spots left
    @sortie = Sortie.find(params[:date_id])
    # sort FIFO-style
    @entry = Entry.get_waitlist(@sortie)
    @left_on_list = Entry.count_left_on_list(@sortie)
  end
  
  def invite
    # call invite method on entries or sortie model
    @sortie = Sortie.find(params[:date_id])
    entry = Entry.find(params[:id])
    
    # call model method
    if entry.invite(current_user) # host: current_user
      url = confirmation_date_url(@sortie)
      code = 'done'
    else
      url = date_entries_path(@sortie)
      code = 'error'
    end
    
    # done => Done!, redirect to confirmation page
    respond_to do |format|
      format.html { redirect_to url }
      format.json {
        render :json => {
          :message => code, # any of error, done
          :redirect_path => url
        }
      }
    end
  end
  
  def pass
    # call invite method on entries or sortie model
    entry = Entry.find(params[:id])
    @sortie = entry.sortie
    
    # call model method
    entry.pass
    
    # removed => new_list
    respond_to do |format|
      format.html { redirect_to date_entries_path(@sortie) }
      format.json {
        
        # FIX REDUNDANCY
        # todo: test for non-existent sortie/not allowed
        # lookup if host has any spots left
        #@sortie = sortie
        # sort FIFO-style
        @entry = Entry.get_waitlist(@sortie)
        @left_on_list = Entry.count_left_on_list(@sortie)
        
        with_format('html') do
          render :json => {
            :message => 'removed', # any of error, removed
            :new_list => render_to_string(:partial => 'waitlist', :layout => false)
          }
        end
      }
    end
  end
  
end
