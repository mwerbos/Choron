class BountiesController < ApplicationController
  before_filter :require_user
  def show
    @bounty = Bounty.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @auction }
    end
  end
    before_filter :require_user
  before_filter :require_admin, :only => [:edit, :new, :destroy, :destroy_with_auction]
  after_filter :clear_admin, only: [:update, :create, :destroy]
  
  # GET /bounties
  # GET /bounties.json
  def index
    @bounties = Bounty.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @bounties }
    end
  end

  # GET /bounties/new
  # GET /bounties/new.json
  def new
    @bounty = Bounty.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @bounty }
    end
  end

  # GET /bounties/1/edit
  def edit
    @bounty = Bounty.find(params[:id])
    @chore_id = @bounty.chore_id
  end

  # POST /bounties
  # POST /bounties.json
  def create
    @bounty = Bounty.new(params[:bounty])
    @chore_id = @bounty.chore_id
    #TODO: Make the bounty get a user's information
    #and update the user parameter accordingly.
    @bounty.user = current_user
    respond_to do |format|
      if @bounty.save && @chore_id != nil
        format.html { redirect_to :bounties, :notice => 'bounty was successfully created.' }
        format.json { render :json => @bounty, :status => :created, :location => @bounty }
      else
        format.html { render :action => "new" }
        format.json { render :json => @bounty.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bounties/1
  # PUT /bounties/1.json
  def update
    @bounty = Bounty.find(params[:id])
    @chore = Chore.find(@bounty.chore_id)
    @chore.save if @chore != nil
    respond_to do |format|
      if @bounty.save
        format.html { redirect_to @bounty, :notice => 'bounty was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @bounty.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bounties/1
  # DELETE /bounties/1.json
  #TODO: Remove this. Bounties should not be destroyed without a chore.
  def destroy
    @bounty = Bounty.find(params[:id])
    @bounty.destroy
    respond_to do |format|
      format.html { redirect_to controller: 'home', action: 'bounty_market' }
      format.json { head :no_content }
    end
  end
  
end
