class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path
    else
      flash.now[:danger] = "Your email or password does not match"
      render sessions_new_path
    end
  end

  def destroy
    session[:user_id] =nil
    redirect_to '/login'
  end
end