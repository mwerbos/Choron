class Auction < ActiveRecord::Base
  require File.join(Rails.root,"lib/delay_utils.rb")
  require File.join(Rails.root,"lib/taxation.rb")
  include DelayUtils
  include Taxation
  include ApplicationHelper
  attr_accessible :expiration_date, :chore_id #explicit use is a bit hacky, oh well
  belongs_to :chore, :counter_cache => true
  has_many :bids
  has_paper_trail
  def lowest()
    if self.bids.empty?
      return MAXBID
    end
    sorted_bids=self.bids.sort {|a,b| bid_sorter(a,b)}
    #sorted_bids_deduped=sorted_bids.group_by{|b| b.user}
    winner=sorted_bids[0].user
    other_bids=sorted_bids.select {|b| b.user!=winner}
    if other_bids.length>0
      other_bids[0].total
    else
      MAXBID
    end
  end
  def dupe_bid?(bid)
    self.bids.select{|b| b.user==bid.user}.sort {|a,b| bid_sorter(a,b)}[0]!=bid
  end
  def low_cut()
    #AFAICT, we don't need this: the second price feature is on the total
    #bid, not on the pot or cut.
    sorted_bids=self.bids.sort {|a,b| bid_sorter(a,b)}
    if sorted_bids.empty?
      nil
    else
      sorted_bids[0].cut
    end
  end

  def toBeat() #Bid required to win the auction
    sorted_bids=self.bids.sort {|a,b| bid_sorter(a,b)}
    if sorted_bids.length>0
      sorted_bids[0].amount-1
    else
      MAXBID
    end
  end

  def close()
    File.open("sharedlog.txt", 'a') {|f| f.write("Closing auction #{self.id}") }
    unless self.bids.empty?
      winner=self.bids.min {|a,b| bid_sorter(a,b)}
      if winner.is_a? SharedBid
        File.open("sharedlog.txt", 'a') {|f| f.write("  Auction is shared") }
        value=winner.amount#This is the fixed pot
        take_tax(winner.user,self.lowest-winner.amount)#This is the cut
        self.chore.delay(run_at: self.chore.due_date).complete
        File.open("sharedlog.txt", 'a') {|f| f.write("  Scheduling chore for: #{self.chore.due_date}") }
      else
        value=self.lowest()
      end
      self.chore.user=winner.user
      self.chore.value=value
      self.chore.save
      return true
    else
      #TODO: figure out what to do if noone bids on anything
      return false
    end
  end
  def user_best(user)
    self.bids.find_all{|bid| bid.user==user}.min {|a,b| bid_sorter(a,b)}
  end
  def open?()
    return self.expiration_date.future?
  end
  def update_attributes(update)
    super
    find_jobs(self,nil,:close).map{|job| job.delete}
    self.delay(:run_at => self.expiration_date).close
  end

end
