class AuthenticatedController < ApplicationController
  before_action :authenticate_user!
  before_action :refresh_access_token!

  private

  def set_raven_context
    Raven.user_context(id: session["warden.user.user.key"]&.first&.first)
    Raven.extra_context(params: params.to_unsafe_h, url: request.url, subdomain: request.subdomain)
  end

  def refresh_access_token!
    return unless current_user.identity.access_token_expired?

    # TODO: Attempt to use the refresh token to update the access_token
    # Skipped for now because it's missing from octokit.

    sign_out(current_user)
    redirect_to user_github_omniauth_authorize_path
  end
end
