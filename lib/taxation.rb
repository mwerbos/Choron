module Taxation
  def take_tax(recipient,amount)
    #I believe that I've fixed the choron leak and the negative collective.
    User.transaction do
      payers=User.where('id not in(?)',[recipient.id])
      numPayers=payers.length
      File.open("#{Rails.root}/testlog.txt", 'w') {|f| f.write(Setting.collective) }
      #This is negative; it will be added to everyone's chorons.
      tax=(-amount+Setting.collective)/numPayers
      Setting.collective+=-(amount+tax*numPayers)
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
