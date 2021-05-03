class Users::SessionsController < Devise::SessionsController
  def new
    # Shows a login page with jut a link to sign in via GitHub.
  end

  def create
    redirect_to user_github_omniauth_authorize_path
  end
end
