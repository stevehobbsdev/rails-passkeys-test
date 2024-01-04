class AccountController < ApplicationController
  before_action :ensure_user
  skip_before_action :verify_authenticity_token

  def index
  end
  
  def passkey_options
    id = WebAuthn.generate_user_id

    options = WebAuthn::Credential.options_for_create(
      user: { id: id, name: @user.email }
    )
    
    # Store the newly generated challenge somewhere so you can have it
    # for the verification phase.
    session[:creation_challenge] = options.challenge
    render json: options
  end

  def register_passkey
    webauthn_creds = WebAuthn::Credential.from_create(params)
    webauthn_creds.verify session[:creation_challenge]

    cred = Credential.new(
      user: @user,
      webauthn_id: webauthn_creds.id,
      public_key: webauthn_creds.public_key,
      sign_count: webauthn_creds.sign_count)

    cred.save!
  end

  def remove_passkey
    @cred = @user.credentials.find_by(params[:id])
  end 

  def confirm_remove_passkey
    passkey_id = params[:passkey_id]

    if @user.password != params[:password]
      flash[:notice] = "Invalid password"
      return render :remove_passkey, status: 401
    end

    cred = @user.credentials.find_by(passkey_id)

    if !cred
      flash[:notice] = "Invalid credential"
      return render :remove_passkey, status: 422
    end

    cred.destroy!
    redirect_to action: :index
  end

  def logout
    session.delete(:user_id)
    redirect_to '/'
  end

end
