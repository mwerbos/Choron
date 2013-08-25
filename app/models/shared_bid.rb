class SharedBid < Bid
  attr_accessible :cut
  validates :cut, numericality: {only_integer: true}
  def total
    amount+cut
  end
end
