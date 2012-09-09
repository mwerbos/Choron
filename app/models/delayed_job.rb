class DelayedJob < ActiveRecord::Base
  attr_accessible :run_at
end
