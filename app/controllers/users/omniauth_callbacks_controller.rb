class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    identity = Identity.from_omniauth(auth).first_or_initialize

    # Build the user if it doesn't exist already
    if identity.user.nil?
      identity.login = auth.info[:nickname]
      identity.user = User.build_from_github_omniauth(auth)
    end

    # https://developer.github.com/apps/building-github-apps/identifying-and-authorizing-users-for-github-apps/
    # Set the access/refresh tokens - We need it to access some of the APIs
    identity.access_token = auth.credentials[:token]
    identity.refresh_token = auth.credentials[:refresh_token]
    identity.save

    if identity.persisted? && identity.user.persisted?
      sign_in_and_redirect(identity.user, event: :authentication)
      set_flash_message(:notice, :success, kind: "GitHub") if is_navigational_format?
    else
      redirect_to root_path, alert: t(".alert")
    end
  end

  def failure
    redirect_to root_path
  end

  private

  def after_sign_in_path_for(_resource)
    session.dig("user_return_to") || root_path
  end

  def auth
    request.env["omniauth.auth"]
  end
end
