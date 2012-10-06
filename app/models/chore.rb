class Chore < ActiveRecord::Base
  attr_accessible :due_date, :name, :value, :done, :auction, :bounty
  belongs_to :user
  has_one :auction
  has_one :bounty
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
end
