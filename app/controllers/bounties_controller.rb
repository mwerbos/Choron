class BountiesController < ApplicationController
  def show
    @bounty = Bounty.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @auction }
    end
  end
end
