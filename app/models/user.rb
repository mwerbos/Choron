class User < ActiveRecord::Base
  acts_as_authentic
  attr_accessible :email, :username, :password, :password_confirmation, :chorons
  has_many :chores
  has_many :bids
  
  def give_chorons(recipient, chorons)
    User.transaction do
      if(self.chorons >= chorons and chorons >= 0 and self != recipient)
        self.chorons = self.chorons - chorons
        recipient.chorons = recipient.chorons + chorons
        return true if recipient.save and self.save
      end
      return false
    end
  end
  def take_tax(amount)
    User.transaction do
      payers=User.where('id not in(?)',[self.id])
      numPayers=payers.length
      File.open("#{Rails.root}/testlog.txt", 'w') {|f| f.write(Setting.collective) }
      #This is negative; it will be added to everyone's chorons.
      tax=(-amount+Setting.collective)/numPayers
      Setting.collective=-(amount+tax*numPayers)
      self.chorons+=amount
      self.save
      payers.each do |payer|
        payer.chorons+=tax
        payer.save
      end
    end
  end
  def prioratized_chores()
    sorted_undone=self.chores.find_all{|chore| not chore.done}.sort{|a,b| a.due_date <=> b.due_date}
    sorted_done=self.chores.find_all{|chore| chore.done}.sort{|b,a| a.due_date <=> b.due_date}
    sorted_undone+sorted_done
  end
  def expected_profit()
    auctions=Auction.where("expiration_date > ?", Time.now)
    total_fees=0#This will be for everyone, not just this user.
    total_income=0
    auctions.each do |auction|
      if auction.bids.min {|a,b| bid_sorter(a,b)}.user==self
        total_income+=auction.lowest
      else
        total_fees+=auction.lowest
      end
    end
    return total_income+(Setting.collective-total_fees)/(User.all.length-1)
  end

end
