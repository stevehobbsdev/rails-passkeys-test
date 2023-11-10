class SigninController < ApplicationController
  def index
  end

  def index_post
    user = User.find_by_email params[:username]

    if !user
      flash[:notice] = "Unable to log in"
      return render :index, status: 401
    end
    
    session[:user_id] = user.id
    redirect_to root_path
  end
end
