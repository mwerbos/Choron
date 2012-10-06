class ChoreScheduler < ActiveRecord::Base
  belongs_to :chore #the last chore it scheduled
  attr_accessible :default_bids, :respawn_time
  serialize :default_bids, Hash

  def schedule_next
    puts 'called schedule_next'
    Chore.transaction do
      #make a new chore that expires (respawn_time) after the current one
      new_chore = Chore.new
      #update the new chore's attributes
      new_chore.name = @chore.name
      new_chore.due_date = @chore.due_date + @respawn_time
      #make a new auction that expires (respawn_time) after the old one
      new_auction = Auction.new
      new_auction.expiration_date = @chore.auction.expiration_date + @respawn_time
      #save both items
      new_chore.auction = new_auction
      new_auction.save
      new_chore.save
    end
    #For some reason this is nil (calls id on nil)
    #puts @chore.id
    #schedule calling this function again in respawn_time
    self.delay( run_at: Time.now + self.respawn_time).schedule_next
    #set to track the new chore, forget about the old one  
    @chore = new_chore
  end

  def self.get_default_bid(user)
    return self.default_bids[user.id]
  end
end
