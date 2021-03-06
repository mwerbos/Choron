class BidsController < ApplicationController
  before_filter :require_user
  # GET /bids
  # GET /bids.json
  def index
    @bids = Bid.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @bids }
    end
  end

  # GET /bids/1
  # GET /bids/1.json
  def show
    @bid = Bid.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @bid }
    end
  end

  # GET /bids/new
  # GET /bids/new.json
  def new
    if not defined? @bid
      shared = Auction.find(params[:auction_id]).chore.is_a?(SharedChore)
      @bid = shared ? SharedBid.new : Bid.new
      @auction_id = params[:auction_id] if params[:auction_id]
      @user_id = current_user.id
    end
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @bid }
    end
  end

  # GET /bids/1/edit
  def edit
    @bid = Bid.find(params[:id])
  end

  # POST /bids
  # POST /bids.json
  def create
    shared = params[:shared_bid] ? true : false
    @bid = shared ? SharedBid.new(params[:shared_bid].merge({:cut => params[:cut]})) : Bid.new(params[:bid])
    puts "**************************************"
    puts @bid.class.name
    puts "**************************************"
    respond_to do |format|
      Bid.transaction do
        if @bid.save and @bid.user.save
          format.html { redirect_to @bid.auction, :notice => "Bid was successfully created."}
          format.json { render :json => @bid, :status => :created, :location => @bid }
        else
          puts "Error saving bid:"
          puts @bid.inspect
          #format.html { render :action => "edit"}
          @auction_id = @bid.auction_id
          @user_id = @bid.user_id
          format.html { render :action => "new"}
          format.json { render :json => @bid.errors, :status => :unprocessable_entity }
        end
      end
    end
    if @bid.auction.chore.chore_scheduler
        @bid.user.auto_preferences([@bid.auction.chore.chore_scheduler])
    end
  end

  # POST /quickbid
  # POST /quickbid.json
  def quickbid
    qb_errors = {}
    params[:amount].each_pair {
      |auction, amount|
      if amount and amount != ""
        cut = params[:cut] ? params[:cut][auction] : nil
        if cut == ""
          next
        end
        bid = (cut ? SharedBid.new({:auction_id => auction, :amount => amount, :cut => cut, :user_id => params[:user_id]}) : Bid.new({:auction_id => auction, :amount => amount, :user_id => params[:user_id]}))
        puts "**************************************"
        puts bid.class.name
        puts "**************************************"
        unless bid.save and bid.user.save
          puts "Error saving bid:"
          puts bid.inspect
          qb_errors[auction] = bid.errors
        end
        if bid.auction.chore.chore_scheduler
          bid.user.auto_preferences([bid.auction.chore.chore_scheduler])
        end
      end
    }
    redirect_to bids_path, flash: { qb_errors: qb_errors }
  end

  # PUT /bids/1
  # PUT /bids/1.json
  def update
    @bid = Bid.find(params[:id])

    respond_to do |format|
      if @bid.update_attributes(params[:bid])
        format.html { redirect_to @bid, :notice => 'Bid was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @bid.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bids/1
  # DELETE /bids/1.json
  def destroy
    @bid = Bid.find(params[:id])
    @bid.destroy

    respond_to do |format|
      format.html { redirect_to bids_url }
      format.json { head :no_content }
    end
  end
end
