class Bid < ActiveRecord::Base
    attr_accessible :amount, :auction_id, :user_id
    belongs_to :auction
    belongs_to :user
    validates :amount, numericality: {only_integer: true}
    validates :user, presence: true
    validates :auction, presence: true
    validate :lowest

    def lowest
        if auction
            lowest_bid=self.auction.lowest
<<<<<<< HEAD
            if self.amount.to_i >= lowest_bid.to_i
=======
            if lowest_bid and self.amount>=lowest_bid
>>>>>>> 38fc78063fffa39c948a6cf6ababd1fbddb91ceb
                errors[:base] << "The bid must be less than #{lowest_bid}"
            end
        end
    end
end
