require "rails_helper"

describe "Users::OmniauthCallbacksController#github", type: :request do
  subject do
    get user_github_omniauth_callback_url(
      subdomain: "app",
      code: "xxxxxxxxxxxxxxxxxxxx",
      state: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    )
  end

  before do
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
      provider: "github",
      uid: "123545",
      credentials: OmniAuth::AuthHash.new({
        expires: true,
        expires_at: (Time.zone.now + 4.hours).to_i,
        refresh_token: "r1.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        token: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      }),
      info: OmniAuth::AuthHash.new({
        id: "123545",
        email: "sample@example.com",
        login: "Sample"
      })
    })
  end

  it do
    expect { subject }.to change(User, :count).by(1).and change(Identity, :count).by(1)

    expect(Identity.last.access_token).to eq("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
    expect(Identity.last.refresh_token).to eq("r1.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
    expect(User.last.identity).to eq(Identity.last)
    expect(response).to have_http_status(:redirect)
  end
end
