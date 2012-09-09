class Auction < ActiveRecord::Base
  include ApplicationHelper
  attr_accessible :expiration_date, :chore_id #explicit use is a bit hacky, oh well
  belongs_to :chore, :counter_cache => true
  has_many :bids
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
  def close()
    winner=self.bids.min {|a,b| bid_sorter(a,b)}.user
    value=self.lowest()
    winner.chorons+=value
    winner.save
    #TAXATION GOES HERE
  end
end
