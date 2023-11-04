class HomeController < ApplicationController
  def index
    redirect_to action: 'login', controller: 'account' unless session[:user_id]

    if session[:user_id]
      @user = User.find(session[:user_id])
    end
  end
end
