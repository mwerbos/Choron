class SharedChoresController < ChoresController
  def contribute
    chore = Chore.find(params[:id])
    user = params[:user]
    chore.contributions[User.where(:username => user)[0]].push Time.now
    chore.save
    redirect_to(:back)
  end

  def uncontribute
    chore = Chore.find(params[:id])
    user = params[:user]
    num = params[:num]
    chore.contributions[User.where(:username => user)[0]].slice! num.to_i
    chore.save
    redirect_to(:back)
  end
end
