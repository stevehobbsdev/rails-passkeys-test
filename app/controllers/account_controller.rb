class AccountController < ApplicationController
  before_action :ensure_user
  skip_before_action :verify_authenticity_token

  def index
    
  end
  
  def passkey_options
    # if !@user.webauthn_id
    #   @user.update!(webauthn_id: WebAuthn.generate_user_id)
    # end
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

end
