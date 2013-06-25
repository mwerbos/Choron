module Taxation
  def take_tax(recipient,amount)
    #This doesn't behave quite like it should; chorons are conserved, but
    #the collective sometimes gets negative amounts.
    User.transaction do
      payers=User.where('id not in(?)',[recipient.id])
      numPayers=payers.length
      File.open("#{Rails.root}/testlog.txt", 'w') {|f| f.write(Setting.collective) }
      #This is negative; it will be added to everyone's chorons.
      tax=(-amount+Setting.collective)/numPayers
      Setting.collective=-(amount+tax*numPayers)
      recipient.chorons+=amount
      recipient.save
      payers.each do |payer|
        payer.chorons+=tax
        payer.save
      end
      payers.each do |payer|
        payer.check_coersion
      end
    end
  end
end
