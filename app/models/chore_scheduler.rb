class ChoreScheduler < ActiveRecord::Base
  belongs_to :chore #the last chore it scheduled
  attr_accessible :default_bids, :respawn_time
  has_paper_trail
  serialize :default_bids, Hash

  def schedule_next(run_at_time)
    old_chore = self.chore
    new_chore = nil
    new_auction = nil
    Chore.transaction do
      #make a new chore that expires (respawn_time) after the current one
      new_chore = old_chore.class.new
      #update the new chore's attributes
      new_chore.name = old_chore.name
      new_chore.due_date = old_chore.due_date + self.respawn_time
      if new_chore.start_date
        old_chore.start_date=old_chore.start_date + self.respawn_time
      end
      #make a new auction that expires (respawn_time) after the old one
      new_auction = Auction.new
      new_auction.expiration_date = old_chore.auction.expiration_date + self.respawn_time
      new_chore.auction = new_auction
      #hacky solution to make it connect the chore to the auction (bad)
      new_chore.auctions_count = 1
      new_chore.chore_scheduler = self
      #save both items
      new_auction.save
      new_chore.save
    end
    #schedule calling this function again in respawn_time
    self.delay( run_at: run_at_time + self.respawn_time).schedule_next(run_at_time + self.respawn_time)
    #also close the auction when it is supposed to be closed
    new_auction.delay(:run_at => new_auction.expiration_date).close
    #set to track the new chore, forget about the old one  
    self.chore = new_chore
    self.save
  end

  def self.get_default_bid(user)
    return self.default_bids[user.id]
  end
end
