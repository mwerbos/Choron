class SharedChore < Chore
  attr_accessible :start_date
  attr_accessible :contributions
  serialize :bid_prefs, Hash
end
