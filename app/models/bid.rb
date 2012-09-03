class Bid < ActiveRecord::Base
  attr_accessible :amount, :auction_id, :user
  belongs_to :auction
  belongs_to :user
end
