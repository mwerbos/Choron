class Auction < ActiveRecord::Base
  require File.join(Rails.root,"lib/delay_utils.rb")
  include DelayUtils
  include ApplicationHelper
  attr_accessible :expiration_date, :chore_id #explicit use is a bit hacky, oh well
  belongs_to :chore, :counter_cache => true
  has_many :bids
  has_paper_trail
  def lowest()
    sorted_bids=self.bids.sort {|a,b| bid_sorter(a,b)}
    if sorted_bids.length>1
      [sorted_bids[0].amount,sorted_bids[1].amount-1].max
    elsif sorted_bids.length==1
      MAXBID-1
    else
      MAXBID
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
    unless self.bids.empty?
      winner=self.bids.min {|a,b| bid_sorter(a,b)}.user
      value=self.lowest()
      self.chore.user=winner
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
