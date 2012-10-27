class ChoreScheduler < ActiveRecord::Base
  belongs_to :chore #the last chore it scheduled
  attr_accessible :default_bids, :respawn_time
  serialize :default_bids, Hash

  def schedule_next(run_at_time)
    old_chore = self.chore
    new_chore = nil
    Chore.transaction do
      #make a new chore that expires (respawn_time) after the current one
      new_chore = Chore.new
      #update the new chore's attributes
      new_chore.name = old_chore.name
      new_chore.due_date = old_chore.due_date + self.respawn_time
      #make a new auction that expires (respawn_time) after the old one
      new_auction = Auction.new
      new_auction.expiration_date = old_chore.auction.expiration_date + self.respawn_time
      new_chore.auction = new_auction
      #hacky solution to make it connect the chore to the auction (bad)
      new_chore.auctions_count = 1
      #save both items
      new_auction.save
      new_chore.save
    end
    #schedule calling this function again in respawn_time
    self.delay( run_at: run_at_time + self.respawn_time).schedule_next(run_at_time + self.respawn_time)
    #set to track the new chore, forget about the old one  
    self.chore = new_chore
    self.save
  end

  def self.get_default_bid(user)
    return self.default_bids[user.id]
  end
end
