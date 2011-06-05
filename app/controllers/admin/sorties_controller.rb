class Admin::SortiesController < Admin::AdminController
  # GET /sorties
  # GET /sorties.xml
  def index
    @sorties = Sortie.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sorties }
    end
  end

  # GET /sorties/1
  # GET /sorties/1.xml
  def show
    @sortie = Sortie.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sortie }
    end
  end

  # GET /sorties/new
  # GET /sorties/new.xml
  def new
    @sortie = Sortie.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sortie }
    end
  end

  # GET /sorties/1/edit
  def edit
    @sortie = Sortie.find(params[:id])
  end

  # POST /sorties
  # POST /sorties.xml
  def create
    @sortie = Sortie.new(params[:sortie])

    respond_to do |format|
      if @sortie.save
        format.html { redirect_to(@sortie, :notice => 'Sortie was successfully created.') }
        format.xml  { render :xml => @sortie, :status => :created, :location => @sortie }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sortie.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sorties/1
  # PUT /sorties/1.xml
  def update
    @sortie = Sortie.find(params[:id])

    respond_to do |format|
      if @sortie.update_attributes(params[:sortie])
        format.html { redirect_to(@sortie, :notice => 'Sortie was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sortie.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sorties/1
  # DELETE /sorties/1.xml
  def destroy
    @sortie = Sortie.find(params[:id])
    @sortie.destroy

    respond_to do |format|
      format.html { redirect_to(sorties_url) }
      format.xml  { head :ok }
    end
  end
end
