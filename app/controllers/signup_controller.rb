class SignupController < ApplicationController
  def index
  end

  def verify
  end

  def callback
  end
  
  def register
    user = User.find_by_email params[:username]

    if user
      flash[:notice] = "User already exists"
      render :index, status: 422
    else
      user = User.new(email: params[:username])
      user.password = params[:password]
      user.save!

      session[:user_id] = user.id
      redirect_to controller: :account, action: :index
    end
  end
end
