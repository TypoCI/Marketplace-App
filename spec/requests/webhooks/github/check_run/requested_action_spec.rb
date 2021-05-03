require "rails_helper"

describe "Webhooks - Github - Check Run - requested_action", type: :request do
  subject do
    post_github_webhook(request_body, headers)
  end

  let(:headers) do
    {
      CONTENT_TYPE: "application/json",
      HTTP_X_GITHUB_EVENT: "check_run"
    }
  end

  let!(:github_check_suite) { create(:github_check_suite) }
  let!(:github_install) { github_check_suite.install }

  let(:request_body) do
    JSON.parse(Rails.root.join("spec", "fixtures", "files", "webhooks", "github", "check_run",
      "requested_action.json").read).tap do |json|
      json["installation"]["id"] = github_install.install_id
      json["check_run"]["external_id"] = github_check_suite.to_gid_param
      json["requested_action"]["identifier"] = "reported"
    end.to_json
  end

  it do
    expect { subject }.to change { github_check_suite.reload.reported? }.from(false).to(true)
  end
end
