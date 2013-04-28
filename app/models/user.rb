class User < ActiveRecord::Base
  include ApplicationHelper
  acts_as_authentic
  attr_accessible :email, :username, :password, :password_confirmation, :chorons, :bid_prefs
  has_many :chores
  has_many :bids
  has_paper_trail
  
  serialize :bid_prefs, Hash
  def give_chorons(recipient, chorons)
    User.transaction do
      if(self.chorons >= chorons and chorons >= 0 and self != recipient)
        self.chorons = self.chorons - chorons
        recipient.chorons = recipient.chorons + chorons
        return true if recipient.save and self.save
      end
      return false
    end
  end
  def take_tax(amount)
    #This doesn't behave quite like it should; chorons are conserved, but
    #the collective sometimes gets negative amounts.
    User.transaction do
      payers=User.where('id not in(?)',[self.id])
      numPayers=payers.length
      File.open("#{Rails.root}/testlog.txt", 'w') {|f| f.write(Setting.collective) }
      #This is negative; it will be added to everyone's chorons.
      tax=(-amount+Setting.collective)/numPayers
      Setting.collective=-(amount+tax*numPayers)
      self.chorons+=amount
      self.save
      payers.each do |payer|
        payer.chorons+=tax
        payer.save
      end
      payers.each do |payer|
        payer.check_coersion
      end
    end
  end
  def prioratized_chores()
    sorted_undone=self.chores.find_all{|chore| not chore.done}.sort{|a,b| a.due_date <=> b.due_date}
    sorted_done=self.chores.find_all{|chore| chore.done}.sort{|b,a| a.due_date <=> b.due_date}
    sorted_undone+sorted_done
  end
  def expected_profit()
    auctions=Auction.where("expiration_date > ?", Time.now)
    total_fees=0#This will be for everyone, not just this user.
    total_income=0
    auctions.each do |auction|
      if not auction.bids.min {|a,b| bid_sorter(a,b)}
        0#Do nothing?
      elsif auction.bids.min {|a,b| bid_sorter(a,b)}.user==self
        total_income+=auction.lowest
      else
        total_fees+=auction.lowest
      end
    end
    chores=Chore.where("done = ? AND auctions_count=1",false)
    chores.each do |chore|
     #This examines all assigned but incomplete chores
      if chore.auction.expiration_date.past? and not chore.value.nil?
        if chore.user==self
          total_income+=chore.value
        else
          puts "MARK"
          puts chore.value.inspect
          total_fees+=chore.value
        end
      end
    end
    return total_income+(Setting.collective-total_fees)/(User.all.length-1)
  end
  def auto_preferences(schedulers=ChoreScheduler.all)
    #This method will attempt to automatically determine the preferences of
    #a user. Preferences are saved as a hash, mapping the ids of open chores
    #to the amount this user would do them for uncoerced. For auctions the
    #user has bid on, their lowest bid will be used. For auctions the user
    #has not bid on, and for bounties, MAXBID is assumed. The user can edit
    #these values; once edited by the user, they won't automaticaly update.
    schedulers.find_all{|scheduler| scheduler.chore.open?}.each do |scheduler|
      chore=scheduler.chore
      if self.bid_prefs[scheduler.id].nil? or
          not self.bid_prefs[scheduler.id][:manual]
        if chore.auction
          my_best_bid=chore.auction.user_best(self)
          if my_best_bid
            self.bid_prefs[scheduler.id]={value:my_best_bid.amount,manual:false}
          else
            self.bid_prefs[scheduler.id]={value:MAXBID,manual:false}
          end
        #elsif chore.bounty
        #  self.bid_prefs[chore.id]={value:MAXBID,manual:false}
        end
      end
    end
    self.save
  end
  def check_coersion()
    #This is not the desired behevior. Desired behevior is:
    #If this shows you're in debt, it sets a job for 2 days
    #from now, notifies you, and coerces you in 2 days.
    if self.chorons<0
      self.coerce
    end
  end
  def coerce(target_EP=0)
    #places bids, taking preferences into account, to raise expected profit
    #to the target level.
    #It's not obvious how to deal with bounties; I'm going to ignore them
    #for now.
    auto_preferences
    extra_needed=target_EP-self.expected_profit
    if extra_needed<=0
      return
    end
    options=self.bid_prefs.collect do |scheduler_id,prefs|
      scheduler=ChoreScheduler.find(scheduler_id)
      chore=scheduler.chore
      #All open chores you won't win:
      if chore.auction and chore.auction.open? and chore.auction.bids.min {|a,b| bid_sorter(a,b)}.user!=self
        {sadness: prefs[:value]-Float(chore.auction.toBeat),
          value: Float(chore.auction.toBeat)+Float(chore.auction.lowest)/(User.count-1), scheduler: scheduler}
      end
    end
    options.compact! #Clears out nils left by collect if the chore is not attached to an unexpired auction.
    min_sadness=nil
    chosen_chores=[]
    for num in 1..options.length
      options.combination(num).each do |option_set|
        value=0
        sadness=0
        option_set.each do |option|
          sadness+=option[:sadness]
          value+=option[:value]
        end
        if value>=extra_needed and (min_sadness.nil? or sadness<min_sadness)
          chosen_chores=option_set
          min_sadness=sadness
        end
      end
    end
    chosen_chores.each do |pref|
      self.bid_prefs[pref[:scheduler][:id]][:manual]=true
    end
    self.save
    chosen_chores.each do |pref|
      auction=pref[:scheduler].chore.auction
      bid=Bid.new(amount:auction.toBeat)
      bid.auction=auction
      bid.user=self
      bid.save!
    end
    return chosen_chores
  end

end
