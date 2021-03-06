class UserSessionsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    if @user = login(params[:email], params[:password], params[:remember_me])
      redirect_back_or_to(:events, notice: 'Login successful')
    else
      redirect_to :back, alert: "Incorrect login information, please try again!"
    end
  end

  def destroy
    logout
    redirect_to(:root, notice: 'Logged out!')
  end
end
