class Auction < ActiveRecord::Base
  attr_accessible :expiration_date, :chore_id #explicit use is a bit hacky, oh well
  belongs_to :chore
  has_many :bids
end
