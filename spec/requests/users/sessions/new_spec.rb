require "rails_helper"

describe "Users::SessionsController#new", type: :request do
  subject do
    get new_user_session_url(subdomain: "app")
  end

  it do
    subject
    expect(response).to have_http_status(:success)
  end
end
