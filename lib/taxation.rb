module Taxation
  def take_tax(recipient,amount,testUser=nil)
    #Now just a convenient wrapper to tax for one person.
    multitax({recipient => 1},amount,testUser)
  end
  def multitax(recipients,amount,testUser=nil)
    puts "----------------"
    puts recipients
    puts amount
    puts testUser
    puts "---------------"
    #recipients should be a map from users to floats.
    #If passed testuser, won't do anything, but will return the change in
    #chorons that user will experience.
    #Here are the properties we want,in order of priority.
    #They may not all be possible:
    #  *Chorons are conserved.
    #  *Chorons are integers.
    #  *The collective is bounded (preferably within [0,N)).
    #  *If there is only one nonzero weight recipient, they should gain exactly
    #    amount.
    #  *The system approximates, as well as possible on average, the case
    #    where everyone is taxed evenly, and then the gains are distributed
    #    proportional to weight.
    #  *There is no difference on average between a bid of A and n bids of A/n.
    #Idea: you could set the total to tax everyone to be the integer such that
    #  1-1/N of it, rounded (down or nearest?) is  equal to amount. Guarenteed
    #  to exist, for any rounding scheme. 
    #  Let's say we're rounding down. Then you take a bit more chorons than you
    #  need. The extras are put into the collective. This doesn't quite take
    #  exactly the correct amount of chorons from everyone in the taxing stage.
    #  However, it's as close as possible. Then I think you just distribute
    #  them according to the best rounding algorithm you have.
    if recipients.length==0
      return 0
    end
    totalWeight=recipients.values.sum
    if totalWeight==0
      return 0
    end
    User.transaction do
      payers=User.where('is_frozen=?',false) 
      numPayers=payers.length
      #This is the amount that the recipients will split.
      adjAmount=(Float(numPayers)/(numPayers-1)*amount).ceil
      #This is negative; it will be added to everyone's chorons.
      #It's the number required to produce the smallest positive collective possible.
      tax=(-adjAmount+Setting.collective)/numPayers
      Setting.collective+=-(adjAmount+tax*numPayers)
      #The merge thing is a hack to map from hashes to hashes
      payments=sum_preserving_round(recipients.merge(recipients){|k,v|Float(adjAmount)*v/totalWeight})
      if testUser
        if payers.include? testUser
          return tax+payments[testUser].to_i
        else
          return payments[testUser].to_i
        end
      else
        User.all.each do |user|
          user.chorons+=payments[user].to_i#to_i converts nil to 0
          if payers.include? user 
            user.chorons+=tax
          end
          user.save
          user.check_coersion
        end
        puts "Adjusted Payment: %i"%adjAmount
        puts "Tax: %i"%tax
      end
    end
  end
  def sum_preserving_round(input)
    #Takes a hash from some keys to floats. Returns a hash with the same keys,
    #and the floats rounded in a error-minimizing way that also preserves their
    #sum. Ties are broken randomly. See:
    #http://stackoverflow.com/questions/792460/how-to-round-floats-to-integers-while-preserving-their-sum
    sum=input.values.sum.round
    temp=input.map{|k,v| {key:k, value:v.floor, diff:v-v.floor}}
    temp.sort_by!{|h| r=rand; [h[:diff],r]}#Sorts with random tiebreaking
    lower_sum=temp.reduce(0){|sum,entry| sum+entry[:value]}
    round_up=Hash[temp[-(sum-lower_sum)..-1].map{|entry| [entry[:key], entry[:value]+1]}]
    round_down=Hash[temp[0..-(sum-lower_sum+1)].map{|entry| [entry[:key], entry[:value]]}]
    round_up.update(round_down)
  end
end
