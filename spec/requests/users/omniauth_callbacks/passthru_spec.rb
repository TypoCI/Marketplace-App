require "rails_helper"

describe "Users::OmniauthCallbacksController#passthru", type: :request do
  subject do
    get user_github_omniauth_authorize_url(subdomain: "app")
  end

  it do
    subject
    expect(response).to have_http_status(:redirect)
  end
end
