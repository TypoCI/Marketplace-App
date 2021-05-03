require "rails_helper"

describe "Users::SessionsController#new", type: :request do
  subject do
    post user_session_url(subdomain: "app")
  end

  it "Redirects somewhere else - We only want signups via GitHub" do
    expect { subject }.not_to change { [User.count, Identity.count] }
    expect(response).to have_http_status(:redirect)
  end
end
