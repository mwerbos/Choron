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

end
