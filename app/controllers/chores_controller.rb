class ChoresController < ApplicationController
  before_filter :require_user
  # GET /chores
  # GET /chores.json
  def index
    @chores = Chore.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @chores }
    end
  end

  # GET /chores/1
  # GET /chores/1.json
  def show
    @chore = Chore.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @chore }
    end
  end
  
  #Takes the chore for current user
  def take_chore
    @chore = Chore.find(params[:id])
    current_user.chores << @chore
    
    respond_to do |format|
      if current_user.save
        format.html { redirect_to current_user, :notice => 'Chore was successfully taken.' }
      else
        format.html { render :action => "take" }
        format.json { render :json => @chore.errors, :status => :unprocessable_entity }
      end
    end
  end

  def complete
    current_chore =Chore.find(params[:id])
    if not current_chore.done
      current_chore.user.chorons+=current_chore.value
      current_chore.done=true
      if current_chore.save and current_chore.user.save
          #format.html { redirect_to(:back), :notice => 'Chore was compleated.' }
        else
          #format.html { render :action => "take" }
          format.json { render :json => @chore.errors, :status => :unprocessable_entity }
        end
    end
    redirect_to(:back)
  end
  def undo
    current_chore =Chore.find(params[:id])
    if current_chore.done
      current_chore.user.chorons-=current_chore.value
      current_chore.done=false
      if current_chore.save and current_chore.user.save
          #format.html { redirect_to(:back), :notice => 'Chore was compleated.' }
        else
          #format.html { render :action => "take" }
          format.json { render :json => @chore.errors, :status => :unprocessable_entity }
        end
    end
    redirect_to(:back)
  end
  # GET /chores/new
  # GET /chores/new.json
  def new
    @chore = Chore.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @chore }
    end
  end

  # GET /chores/1/edit
  def edit
    @chore = Chore.find(params[:id])
  end

  # POST /chores
  # POST /chores.json
  def create
    @chore = Chore.new(params[:chore])

    respond_to do |format|
      if @chore.save
        format.html { redirect_to :chores, :notice => 'Chore was successfully created.' }
        format.json { render :json => @chore, :status => :created, :location => @chore }
      else
        format.html { render :action => "new" }
        format.json { render :json => @chore.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /chores/1
  # PUT /chores/1.json
  def update
    @chore = Chore.find(params[:id])

    respond_to do |format|
      if @chore.update_attributes(params[:chore])
        format.html { redirect_to @chore, :notice => 'Chore was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @chore.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /chores/1
  # DELETE /chores/1.json
  def destroy
    @chore = Chore.find(params[:id])
    @chore.destroy

    respond_to do |format|
      format.html { redirect_to chores_url }
      format.json { head :no_content }
    end
  end
end
