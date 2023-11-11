class SigninController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :verify_passkey

  def index
  end

  def index_post
    user = User.includes(:credentials).find_by_email(params[:username])

    if !user
      flash[:notice] = "Unable to log in"
      return render :index, status: 401
    end

    session[:signin_id] = user.id

    if user.credentials.any?
      redirect_to action: :passkey  
    else
      redirect_to action: :password
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

  def passkey
  end

  def passkey_options
    user = User.find(session[:signin_id])
    options = WebAuthn::Credential.options_for_get(allow: user.credentials.map { |c| c.webauthn_id })
    session[:authentication_challenge] = options.challenge
    render json: options
  end

  def verify_passkey
    webauthn_creds = WebAuthn::Credential.from_get(params)
    stored_credential = Credential.find_by(webauthn_id: webauthn_creds.id)

    raise 'No user' unless stored_credential

    webauthn_creds.verify(
      session[:authentication_challenge],
      public_key: stored_credential.public_key,
      sign_count: stored_credential.sign_count
    )

    stored_credential.update! sign_count: webauthn_creds.sign_count
    session[:user_id] = stored_credential.user_id
    render json: { success: true }
  end
end
