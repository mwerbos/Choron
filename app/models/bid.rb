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
            if lowest_bid and self.amount>=lowest_bid
                errors[:base] << "The bid must be less than #{lowest_bid}"
            end
        end
    end
end
