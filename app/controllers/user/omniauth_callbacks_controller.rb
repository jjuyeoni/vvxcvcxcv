# frozen_string_literal: true

class User::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  layout "user-application"
  def self.provides_callback_for(provider)
    class_eval %Q{
      def #{provider}
        @user = User.find_for_oauth(request.env["omniauth.auth"], current_user)
        
        if @user.persisted?
          sign_in_and_redirect @user, event: authenticate_user!
        else
          session["devise.#{provider}_data"] = request.env["omniauth.auth"]
          redirect_to new_user_registration_url
        end
      end
    }
  end
  
  [:google_oauth2, :facebook, :naver].each do |provider|
    provides_callback_for provider
  end
  
  def after_sign_in_path_for(resource)
    auth = request.env['omniauth.auth']
    @identity = Identity.find_for_oauth(auth)
    @user = User.find(current_user.id)
    if @user.persisted?
      root_path
    else
      home_index_path
    end
  end
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
