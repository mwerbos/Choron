class SharedChore < Chore
  attr_accessible :contributions, :cut
  #Contributions is a hash from users to lists of datetimes when they did it.
  serialize :contributions, Hash
  def expected_value(testUser)
    if self.done
      return 0
    else
      return multitax(self.contributions.merge(self.contributions){|k,v|v.length},self.value,testUser)
    end
  end
  def complete()
    #This should be called from the delayed jobs table.
    unless self.done
      unless self.contributions.empty?
          multitax(self.contributions.merge(self.contributions){|k,v|v.length},self.value)
      end
      self.done=true
      Chore.transaction{self.save and self.user.save}
    end
  end
  def active?()
    #Maybe add bounties for shared chores? idk...
    !self.done && (self.start_date.nil? || self.start_date.past?) && (self.auction.nil? || self.auction.expiration_date.past?)
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
