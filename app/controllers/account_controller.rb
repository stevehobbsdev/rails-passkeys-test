class AccountController < ApplicationController
  before_action :ensure_user, except: [:login, :do_login]
  skip_before_action :verify_authenticity_token

  def login
    @user = User.find(session[:user_id]) if session[:user_id]

    if @user
      if @user.webauthn_id
        redirect_to action: 'verify'
      else
        redirect_to action: 'register'
      end
    end
  end
  
  def register
    if !@user.webauthn_id
      @user.update!(webauthn_id: WebAuthn.generate_user_id)
    end

    options = WebAuthn::Credential.options_for_create(
      user: { id: @user.webauthn_id, name: @user.email }
    )
    
    # Store the newly generated challenge somewhere so you can have it
    # for the verification phase.
    session[:creation_challenge] = options.challenge
    @webauthn_options = JSON.generate(options.as_json)
  end

  def register_callback
    webauthn_creds = WebAuthn::Credential.from_create(params)
    webauthn_creds.verify session[:creation_challenge]
    @user.update! webauthn_id: webauthn_creds.id, public_key: webauthn_creds.public_key, sign_count: webauthn_creds.sign_count
  end

  def verify
    options = WebAuthn::Credential.options_for_get(allow: [@user.webauthn_id])
    session[:authentication_challenge] = options.challenge
    @webauthn_options = JSON.generate(options.as_json)
  end

  def verify_callback
    webauthn_creds = WebAuthn::Credential.from_get(params)
    stored_user = User.find_by webauthn_id: webauthn_creds.id

    raise 'No user' unless stored_user

    webauthn_creds.verify(
      session[:authentication_challenge],
      public_key: stored_user.public_key,
      sign_count: stored_user.sign_count
    )

    stored_user.update! sign_count: webauthn_creds.sign_count

    render json: { success: true }
  end

  def logout
    session.delete(:user_id)
    redirect_to '/'
  end

  def do_login
    user = User.find_by email: params[:username]

    unless user
      user = User.create email: params[:username]
    end

    session[:user_id] = user.id
    
    if !user.webauthn_id
      redirect_to action: 'register'
    else
      redirect_to action: 'verify'
    end
  end

end
