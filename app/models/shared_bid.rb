class SharedBid < Bid
  attr_accessible :cut
  validates :cut, numericality: {only_integer: true}
end
