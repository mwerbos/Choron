class SharedChoresController < ChoresController
  def uncontribute
    chore = Chore.find(params[:id])
    user = params[:user]
    num = params[:num]
    chore.contributions[User.where(:username => user)[0]].slice! num.to_i
    chore.save
    redirect_to(:back)
  end
end
