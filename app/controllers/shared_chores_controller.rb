class SharedChoresController < ChoresController
  def contribute
    chore = Chore.find(params[:id])
    if chore.due_date.future? 
      if chore.contributions[current_user]
        chore.contributions[current_user].push Time.now
      else
        chore.contributions[current_user]=[Time.now]
      end
      chore.save
    end
    redirect_to(:back)
  end

  def uncontribute
    chore = Chore.find(params[:id])
    if chore.due_date.future? 
      num = params[:num]
      chore.contributions[current_user].slice! num.to_i
      chore.save
    end
    redirect_to(:back)
  end
end
