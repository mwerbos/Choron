class Bid < ActiveRecord::Base
    has_paper_trail
    attr_accessible :amount, :auction_id, :user_id, :expiration_date
    belongs_to :auction
    belongs_to :user
    validates :amount, numericality: {only_integer: true, greater_than: 0}
    validates :user, presence: true
    validates :auction, presence: true
    validate :lowest
    validate :isOpen

    def total
      self.amount
    end
    def lowest
        if auction and self.total
            lowest_bid=self.auction.lowest
            if lowest_bid and self.total>=lowest_bid
                errors[:base] << "The bid must be less than #{lowest_bid}"
            end
        end
    end
    def isOpen
      if auction and auction.expiration_date.past?
        errors[:base] << "This auction is closed."
      end
    end
end
