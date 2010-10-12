class WaitlistEntriesController < ApplicationController
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
