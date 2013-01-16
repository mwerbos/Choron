class ChoresController < ApplicationController
  before_filter :require_user
  before_filter :require_admin, :only => [:edit, :destroy]
  after_filter :clear_admin, only: [:update]
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
      if current_chore.auction
        if current_chore.user==current_user
          current_chore.user.take_tax(current_chore.value)
          current_chore.done=true
          Chore.transaction{current_chore.save and current_chore.user.save}
        end
      elsif current_chore.bounty and current_chore.due_date.future?
       current_chore.user=current_user
       current_chore.done=true
       current_user.chorons+=current_chore.value
       current_chore.bounty.user.chorons-=current_chore.value
       Chore.transaction do
         current_user.save
         current_chore.save
         current_chore.bounty.user.save
       end
      end
    end
    redirect_to(:back)
  end
  def undo
    current_chore =Chore.find(params[:id])
    if current_chore.user==current_user and current_chore.done
      if current_chore.auction
        current_chore.user.take_tax(-current_chore.value)
        current_chore.done=false
        Chore.transaction do
          current_chore.save
          current_chore.user.save
        end
      elsif current_chore.bounty
       current_chore.user=nil
       current_chore.done=false
       current_user.chorons-=current_chore.value
       current_chore.bounty.user.chorons+=current_chore.value
       Chore.transaction do
         current_user.save
         current_chore.save
         current_chore.bounty.user.save
       end
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
    #Check if the chore has a scheduler with a nonzero respawn time
    #If it does, take the user to the recurring chore deletion page
    if(@chore.chore_scheduler != nil and @chore.chore_scheduler.respawn_time != 0)
      puts "DEBUG: This is a recurring chore!"
      respond_to do |format|
        format.html
        format.json { render :json => @chore }
      end
    #If not, just destroy it, and take it to the chores url
    else
      @chore.destroy
      respond_to do |format|
        format.html { redirect_to controller: 'home', action: 'chore_market' }
        format.json { head :no_content }
      end
    end
  end
  
  def destroy_repeating_chore
    if params[:nevermind_button]
      respond_to do |format|
        format.html { redirect_to controller: 'home', action: 'chore_market' }
        format.json { head :no_content }
      end
    else 
      @chore = Chore.find(params[:id])
      if params[:all_button]
        puts "DEBUG: Delete it all!!11one1!"
        @chore.chore_scheduler.delete
        @chore.delete
        respond_to do |format|
         format.html { redirect_to controller: 'home', action: 'chore_market' }
          format.json { head :no_content }
        end
      else 
        if params[:instance_button]
          puts "DEBUG: Just delete this instance, please."
          @chore.chore_scheduler.schedule_next(Time.now)
          @chore.delete
          respond_to do |format|
            format.html { redirect_to controller: 'home', action: 'chore_market' }
            format.json { head :no_content }
          end
        end
      end
    end
  end

end
