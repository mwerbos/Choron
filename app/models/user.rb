class User < ActiveRecord::Base
  acts_as_authentic
  attr_accessible :email, :username, :password, :password_confirmation, :chorons, :bid_prefs
  has_many :chores
  has_many :bids
  
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
      if chore.auction.expiration_date.past? #This examines all assigned but incomplete chores
        if chore.value.nil?
          #This should't really happen; it would indicate a failure of the
          #auction to execute close() when its expiration passes.
          unless chore.auction.close()
            break
          end
        end
        if chore.user==self
          total_income+=chore.value
        else
          total_fees+=chore.value
        end
      end
    end
    return total_income+(Setting.collective-total_fees)/(User.all.length-1)
  end
  def auto_preferences(chores=Chore.all)
    #This method will attempt to automatically determine the preferences of
    #a user. Preferences are saved as a hash, mapping the ids of open chores
    #to the amount this user would do them for uncoerced. For auctions the
    #user has bid on, their lowest bid will be used. For auctions the user
    #has not bid on, and for bounties, MAXBID is assumed. The user can edit
    #these values; once edited by the user, they won't automaticaly update.
    chores.find_all{|chore| chore.open?}.each do |chore|
      if self.bid_prefs[chore.id].nil? or
          not self.bid_prefs[chore.id][:manual]
        if chore.auction
          my_best_bid=chore.auction.user_best(self)
          if my_best_bid
            self.bid_prefs[chore.id]={value:my_best_bid.amount,manual:false}
          else
            self.bid_prefs[chore.id]={value:MAXBID,manual:false}
          end
        elsif chore.bounty
          self.bid_prefs[chore.id]={value:MAXBID,manual:false}
        end
      end
    end
    self.save
  end
  def coerce(target_EP=0)
    #places bids, taking preferences into account, to raise expected profit
    #to the target level.
    #It's not obvious how to deal with bounties; I'm going to ignore them
    #for now.
    auto_preferences
    extra_needed=target_EP-self.expected_profit
    options=self.bid_prefs.collect do |chore_id,prefs|
      chore=Chore.find(chore_id)
      if chore.auction
        puts "LOOP!"
        {preference_ratio: Float(chore.auction.lowest-1)/prefs[:value],
          value: Float(chore.auction.lowest-1), chore: chore}
      end
    end
    options.sort!{|a,b| a[:preference_ratio]<=>b[:preference_ratio]}
    chosen_chores=options.take_while do |option|
      puts option
      continue=extra_needed>0
      extra_needed-=option[:value]
      continue#Returns false the iteration after the last one needed
    end
    chosen_chores.each do |pref|
      self.bid_prefs[pref[:chore][:id]][:manual]=true
    end
    self.save
    worst_ratio=chosen_chores.last[:preference_ratio]
    #chosen_chores.each do |pref|
    #  bid=Bid.new(amount:worst_ratio*pref[:value],auction_id


    return chosen_chores
  end

end
