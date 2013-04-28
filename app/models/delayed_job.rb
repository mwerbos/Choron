class DelayedJob < ActiveRecord::Base
  has_paper_trail
  attr_accessible :run_at
end
