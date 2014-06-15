class Chore < ActiveRecord::Base
  require File.join(Rails.root,"lib/taxation.rb")
  include Taxation
  attr_accessible :due_date, :name, :value, :done, :auction, :bounty, :auctions_count, :start_date
  belongs_to :user
  has_one :auction
  has_one :bounty
  belongs_to :chore_scheduler #might be nil if it is a one-time chore
  has_paper_trail
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
  def expected_value(testUser)
    if self.done
      return 0
    else
      return take_tax(self.user,self.value,testUser)
    end
  end
  def complete(current_user)
    if not self.done
      if self.auction
        if self.user==current_user
          take_tax(self.user,self.value)
          self.done=true
          Chore.transaction{self.save and self.user.save}
        end
      elsif self.bounty and self.due_date.future?
       self.user=current_user
       self.done=true
       current_user.chorons+=self.value
       self.bounty.user.chorons-=self.value
       Chore.transaction do
         current_user.save
         self.save
         self.bounty.user.save
       end
      end
    end
  end
  def complete_coop(recipients,current_user)
    if not self.done and self.auction and self.user==current_user
      Chore.transaction do
        multitax(recipients,self.value)
        self.done=true
        self.save
      end
    end
  end
  def undo(current_user)
    if self.user==current_user and self.done
      if self.auction
        take_tax(self.user,-self.value)
        self.done=false
        Chore.transaction do
          self.save
          self.user.save
        end
      elsif self.bounty
       self.user=nil
       self.done=false
       current_user.chorons-=self.value
       self.bounty.user.chorons+=self.value
       Chore.transaction do
         current_user.save
         self.save
         self.bounty.user.save
       end
      end
    end
  end

  def get_pref(user)
    if self.chore_scheduler
      return user.bid_prefs[self.chore_scheduler.id]
    else
      return nil
    end
  end
end
