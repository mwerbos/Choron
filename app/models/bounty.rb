class Bounty < ActiveRecord::Base
  has_paper_trail
  attr_accessible :chore_id, :user_id
  belongs_to :chore, :counter_cache => true
  belongs_to :user
end
