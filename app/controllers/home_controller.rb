class HomeController < ApplicationController
  before_filter :require_user
  
  def my_chores
    #grabs user data to display chores in the template
    @user = current_user

    respond_to do |format|
      format.html # my_chores.html.erb
      format.json { render :json => @user }
    end
  end
  
  def chore_market
    #retrieves all chores in the view specified
    #(open, all, or closed)
    @view = params[:view] ? params[:view] : 'open'
    @chores = Chore.where(:auctions_count => 1)
    #displays them with templatehere
  end
  
  def give_chorons_form
    #gets user id from url parameters
    #displays form asking for amount of chorons
  end
  
  def give_chorons
    #uses parameters to find out
    #how many chorons were given and to whom
    #processes request in database
    #if both objects saved, display success
  end
  
  def give_chore_form
    #gets user id from url parameters
    #displays form asking for amount of chorons
  end
  
  def give_chore
    #uses parameters to find out
    #how many chorons were given and to whom
    #processes request in database
    #if both objects saved, display success
  end
  
  def new_chore_auction
    #has a form that creates both a chore and auction
    #and associates them
  end
  
end