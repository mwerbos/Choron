class SharedChoresController < ChoresController
  def contribute
    chore = Chore.find(params[:id])
    if chore.contributions[current_user]
      chore.contributions[current_user].push Time.now
    else
      chore.contributions[current_user]=[Time.now]
    end
    chore.save
    redirect_to(:back)
  end

  def uncontribute
    chore = Chore.find(params[:id])
    num = params[:num]
    chore.contributions[current_user].slice! num.to_i
    chore.save
    redirect_to(:back)
  end
end
