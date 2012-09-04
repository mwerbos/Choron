class Auction < ActiveRecord::Base
  include ApplicationHelper
  attr_accessible :expiration_date, :chore_id #explicit use is a bit hacky, oh well
  belongs_to :chore, :counter_cache => true
  has_many :bids
  def lowest()
      sorted_bids=self.bids.sort {|a,b| bid_sorter(a,b)}
      [sorted_bids[0].amount,sorted_bids[1].amount-1].max
  end
end
