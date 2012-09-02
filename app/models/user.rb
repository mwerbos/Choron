class User < ActiveRecord::Base
  acts_as_authentic
  attr_accessible :email, :username, :password, :password_confirmation
  has_many :chores
  has_many :bids
end
