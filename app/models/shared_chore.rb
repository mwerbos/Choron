class SharedChore < Chore
  attr_accessible :start_date
  attr_accessible :contributions
  #Contributions is a hash from users to lists of datetimes when they did it.
  serialize :contributions, Hash
  def complete()
    #This should be called from the delayed jobs table.
      multitax(self.contributions.merge(self.contributions){|k,v|v.length},self.value)
      self.done=true
      Chore.transaction{self.save and self.user.save}
  end
  def active?()
    #Maybe add bounties for shared chores? idk...
    !self.done && self.start_date.past? && (self.auction.nil? || self.auction.expiration_date.past?)
  end
  def num_contributions(user=nil)
    if user.nil?
      all_contribs=self.contributions.values.sum
      if all_contribs==0#The result of calling sum on an empty list
        return 0
      else
        return all_contribs.length
      end
    elsif self.contributions[user]
      self.contributions[user].length
    else
      0
    end
  end
end
