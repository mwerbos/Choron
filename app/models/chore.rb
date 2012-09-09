class Chore < ActiveRecord::Base
  attr_accessible :due_date, :name, :value, :done
  belongs_to :user
  has_one :auction
end
