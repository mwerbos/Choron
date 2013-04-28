class ChoresController < ApplicationController
  before_filter :require_user
  before_filter :require_admin, :only => [:edit, :new, :destroy, :destroy_with_auction]
  after_filter :clear_admin, only: [:update, :create, :destroy]
  
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
    Chore.find(params[:id]).complete(current_user)
    redirect_to(:back)
  end
  def undo
    Chore.find(params[:id]).undo(current_user)
    redirect_to(:back)
  end
  def coop
    @chore =Chore.find(params[:id])
    unless (not @chore.done) and @chore.auction and @chore.user==current_user
      #If the above conditions aren't met, this should not work.
      redirect_to(:back)
    end
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
  
  def destroy_with_auction
    @chore = Chore.find(params[:id])
    @auction = @chore.auction
    #Check if the chore has a scheduler with a nonzero respawn time
    #If it does, take the user to the recurring chore deletion page
    if(@chore.chore_scheduler != nil and @chore.chore_scheduler.respawn_time != 0)
      puts "DEBUG: This is a recurring chore!"
      respond_to do |format|
        format.html { render 'chores/destroy' }
        format.json { render :json => @chore }
      end
    #If not, just destroy it, and take it to the chores url
    else
      @chore.destroy
      @auction.destroy if @auction != nil
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
        @auction.destroy if @auction != nil
        respond_to do |format|
         format.html { redirect_to controller: 'home', action: 'chore_market' }
          format.json { head :no_content }
        end
      else 
        if params[:instance_button]
          puts "DEBUG: Just delete this instance, please."
          @chore.chore_scheduler.schedule_next(Time.now)
          @chore.delete
          @auction.destroy if @auction != nil
          respond_to do |format|
            format.html { redirect_to controller: 'home', action: 'chore_market' }
            format.json { head :no_content }
          end
        end
      end
    end
  end

end
