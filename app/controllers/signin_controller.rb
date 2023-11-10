class SigninController < ApplicationController
  def index
  end

  def index_post
    user = User.includes(:credentials).find_by_email(params[:username])

    if !user
      flash[:notice] = "Unable to log in"
      return render :index, status: 401
    end

    if user.credentials.any?
    
    else
      session[:signin_id] = user.id
      return redirect_to action: :password
    end
  end

  def password
    redirect_to root_path if !session[:signin_id]
    @signin_id = session[:signin_id]
  end

  def verify_password
    signin_id = params[:signin_id]
    redirect_to root_path if !session[:signin_id]

    user = User.find(signin_id)

    if user.password != params[:password]
      flash[:notice] = "Unable to sign in"
      return render :password, status: 401
    end

    session[:user_id] = user.id
    session.delete(:signin_id)
    redirect_to root_path
  end
end
