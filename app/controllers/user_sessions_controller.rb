class UserSessionsController < ApplicationController
    before_filter :require_user, :except => ['new', 'create']

  # GET /user_sessions/new
  # GET /user_sessions/new.json
  def new
    @user_session = UserSession.new

    respond_to do |format|
      if current_user
        format.html { redirect_to :users }
        format.json { redirect_to :users }
      else
        format.html # new.html.erb
        format.json { render :json => @user_session }
      end
    end
  end

  # POST /user_sessions
  # POST /user_sessions.json
  def create
    @user_session = UserSession.new(params[:user_session])

    respond_to do |format|
      if @user_session.save
        format.html { redirect_to(:home, :notice => 'Login successful.') }
        format.json { render :json => @user_session, :status => :created, :location => @user_session }
      else
        format.html { render :action => "new" }
        format.json { render :json => @user_session.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_sessions/1
  # DELETE /user_sessions/1.json
  def destroy
    @user_session = UserSession.find
    @user_session.destroy

    respond_to do |format|
      format.html { redirect_to(:users, :notice => 'Goodbye!') }
      format.json { head :no_content }
    end
  end

  def make_admin
    flash[:notice]=session[:current_admin_status]
    verification_options = 
      ['I solemnly swear that I am not about to be a dick.',
       'I will handle the nuclear codes responsibly.',
       'Twilight, I\'ll be good! I pinky-promise!',
       'I will be true. You have my word of honor. And my axe.']
    choice = Random.rand(verification_options.length)
    @verification_text = verification_options[choice]
    respond_to do |format|
      format.html
      format.json { render :json => @user_session }
    end
  end

  def confirm_admin
    user_verification = params[:user_verification].lstrip.rstrip
    if user_verification==params[:verification_text]
      puts "**********************CORRECT!!!"
      puts "*****CURRENT ADMIN STATUS (IN CONFIRM_ADMIN): ", session[:current_admin_status]
      set_admin_true
      redirect_back
      #redirect_to(controller: 'home', action: 'chore_market')
      return
    end
    redirect_back
    #redirect_to(controller: 'home', action: 'my_chores')
    #TODO: make it redirect to desired page
  end

end
