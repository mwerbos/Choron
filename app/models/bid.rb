class Bid < ActiveRecord::Base
  attr_accessible :amount, :auction_id
  belongs_to :auction
  belongs_to :user
end
