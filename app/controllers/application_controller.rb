class ApplicationController < ActionController::Base
  def ensure_user
    id = session[:user_id]
    raise 'No id' unless id

    user = User.find(id)
    raise 'No user' unless user

    @user = user
  end
end
