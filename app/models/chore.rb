class Chore < ActiveRecord::Base
  attr_accessible :due_date, :name, :value, :done, :auction, :bounty, :auctions_count
  belongs_to :user
  has_one :auction
  has_one :bounty
  has_one :chore_scheduler #might be nil if it is a one-time chore
  accepts_nested_attributes_for :auction
  def open?
    if self.bounty
      return (not self.done and self.due_date.future?)
    elsif self.auction
      return self.auction.expiration_date.future?
    else
      return true
    end
  end
  def end_date
    if self.bounty
      return self.due_date
    elsif self.auction
      return self.auction.expiration_date
    else
      return nil
    end
  end
end
