class HomeController < ApplicationController
  before_filter :require_user
  
  def my_chores
    #grabs user data to display chores in the template
    @user = current_user

    respond_to do |format|
      format.html # my_chores.html.erb
      format.json { render :json => @user }
    end
  end
  
  def chore_market
    #retrieves all chores in the view specified
    #(open, all, or closed)
    @view = params[:view] ? params[:view] : 'all'
    #@chores = Chore.where(:auctions_count => 1)
    @chores = Chore.where("bounties_count=1 OR auctions_count=1")
    #displays them with templatehere
  end
  
  def make_chore_auction_form
    #makes new chore object for form structure
    @chore = Chore.new
    #makes auction object and attaches it
    @auction = Auction.new
    @auction.chore = @chore
    respond_to do |format|
      format.html # make_chore_auction_form.html.erb
      format.json { render :json => @user }
    end
  end
  
  def make_chore_auction
    @auction = Auction.new(params[:chore][:auction])
    chore_params=params[:chore]
    chore_params[:auction]=@auction
    @chore = Chore.new(chore_params)
    @auction.chore = @chore
    Auction.transaction do
      respond_to do |format|
        if @auction.save and @chore.save
          format.html { redirect_to('/home/chore_market', :notice => 'Chore auction created.') }
          format.json { render :json }
        else
          format.html { redirect_to('/home/chore_market', :notice => 'Could not create chore auction.') }
          format.json { render :json => @user_session.errors, :status => :unprocessable_entity }
        end
      end
    end
    if params[:respawn] != 0
      @scheduler = ChoreScheduler.new(:respawn_time => params[:respawn], default_bids: {} )
      @scheduler.chore = @chore
      @scheduler.save
      run_at = Time.now + @scheduler.respawn_time
      @scheduler.delay(run_at: run_at).schedule_next(run_at)
    end
  end
  
  def give_chorons_form
    #gets user id from url parameters
    @user = User.find(params[:user_id])
    #displays form asking for amount of chorons
    respond_to do |format|
      format.html # give_chorons_form.html.erb
      format.json { render :json => @user }
    end
  end
  
  def give_chorons
    #uses parameters to find out
    #how many chorons were given and to whom
    @chorons = params[:user][:chorons].to_i
    @recipient = User.find(params[:user][:user_id])
    @giver = current_user
    #processes request in database
    success = @giver.give_chorons(@recipient, @chorons)
    #if both objects saved, display success
    respond_to do |format|
      if success
        format.html { redirect_to(@recipient, :notice => 'Gift successful.') }
        format.json { render :json }
      else
        format.html { redirect_to(@recipient, :notice => 'Gift could not be processed.') }
        format.json { render :json => @user_session.errors, :status => :unprocessable_entity }
      end
    end
  end
  def get_preferences_list
    @prefs = current_user.bid_prefs
  end
  def show_preference
    @user= current_user
    respond_to do |format|
      format.html # make_chore_auction_form.html.erb
      format.json { render :json => @user }
    end

  end
  def edit_preference
    @user=current_user
    @user.bid_prefs[Integer(params[:chore_id])]=
        {value: params[:value],manual: params[:manual]}
    unless params[:manual]
      @user.auto_preferences([Chore.find(params[:chore_id])])
    end
    respond_to do |format|
      if @user.save
        format.html { redirect_to('/home/preferences', :notice => 'Preferences edited.') }
        format.json { render :json }
      else
        format.html { redirect_to('/home/preferences', :notice => 'Could not create chore auction.') }
        format.json { render :json => @user_session.errors, :status => :unprocessable_entity }
      end
    end
  end
     
  
  def give_chore_form
    #gets user id from url parameters
    #displays form asking for amount of chorons
  end
  
  def give_chore
    #uses parameters to find out
    #how many chorons were given and to whom
    #processes request in database
    #if both objects saved, display success
  end

  
end
