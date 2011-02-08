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
  end
  
  def invite
    # call invite method on entries or activity model
    entry = WaitlistEntry.find(params[:entry])
    
    # call model method
    entry.invite(current_user) # host: current_user
    
    # done => Done!, redirect to confirmation page
    respond_to do |format|
      format.html { redirect_to :action => :confirmation }
      format.js {
        render :json => {
          :message => 'done', # any of error, done
          :redirect_path => url_for(:action => :confirmation, :id => 0) # fix
        }, :content_type => 'application/json'
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
      format.js {
        
        # FIX REDUNDANCY
        # todo: test for non-existent activity/not allowed
        # lookup if host has any spots left
        @activity = activity
        # sort FIFO-style
        @entry = WaitlistEntry.get_waitlist(@activity)
        @left_on_list = WaitlistEntry.count_left_on_list(@activity)
        
        render :json => {
          :message => 'removed', # any of error, removed
          :new_list => render_to_string(:action => :waitlist, :id => activity.id, :layout => false)
        }, :content_type => 'application/json'
      }
    end
  end
  
  # GET /waitlist_entries
  # GET /waitlist_entries.xml
  def index
    @waitlist_entries = WaitlistEntry.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @waitlist_entries }
    end
  end

  # GET /waitlist_entries/1
  # GET /waitlist_entries/1.xml
  def show
    @waitlist_entry = WaitlistEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @waitlist_entry }
    end
  end

  # GET /waitlist_entries/new
  # GET /waitlist_entries/new.xml
  def new
    @waitlist_entry = WaitlistEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @waitlist_entry }
    end
  end

  # GET /waitlist_entries/1/edit
  def edit
    @waitlist_entry = WaitlistEntry.find(params[:id])
  end

  # POST /waitlist_entries
  # POST /waitlist_entries.xml
  def create
    @waitlist_entry = WaitlistEntry.new(params[:waitlist_entry])

    respond_to do |format|
      if @waitlist_entry.save
        format.html { redirect_to(@waitlist_entry, :notice => 'Waitlist entry was successfully created.') }
        format.xml  { render :xml => @waitlist_entry, :status => :created, :location => @waitlist_entry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @waitlist_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /waitlist_entries/1
  # PUT /waitlist_entries/1.xml
  def update
    @waitlist_entry = WaitlistEntry.find(params[:id])

    respond_to do |format|
      if @waitlist_entry.update_attributes(params[:waitlist_entry])
        format.html { redirect_to(@waitlist_entry, :notice => 'Waitlist entry was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @waitlist_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /waitlist_entries/1
  # DELETE /waitlist_entries/1.xml
  def destroy
    @waitlist_entry = WaitlistEntry.find(params[:id])
    @waitlist_entry.destroy

    respond_to do |format|
      format.html { redirect_to(waitlist_entries_url) }
      format.xml  { head :ok }
    end
  end
end
