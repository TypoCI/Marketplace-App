require "rails_helper"

describe "Webhooks - Github - Pull Request - synchronize", type: :request do
  subject do
    post_github_webhook(request_body, headers)
  end

  let(:headers) do
    {
      CONTENT_TYPE: "application/json",
      HTTP_X_GITHUB_EVENT: "pull_request"
    }
  end

  let!(:github_install) { create(:github_install) }

  let(:request_body) do
    JSON.parse(Rails.root.join("spec", "fixtures", "files", "webhooks", "github", "pull_request",
      "synchronize.json").read).tap do |json|
      json["installation"]["id"] = github_install.install_id
    end.to_json
  end

  it do
    expect { subject }.to change(github_install.check_suites, :count).by(1)
      .and have_enqueued_job(Github::CheckSuites::RequestedJob)
  end

  context "With a chuck suite for that last commit" do
    let(:github_check_suite) { create(:github_check_suite, :no_pull_requests, install: github_install) }

    let(:request_body) do
      JSON.parse(Rails.root.join("spec", "fixtures", "files", "webhooks", "github", "pull_request",
        "opened.json").read).tap do |json|
        json["installation"]["id"] = github_install.install_id
        json["repository"]["full_name"] = github_check_suite.repository_full_name
        json["pull_request"]["head"]["sha"] = github_check_suite.head_sha
        json["pull_request"]["head"]["ref"] = github_check_suite.head_branch
        json["pull_request"]["base"]["sha"] = github_check_suite.base_sha
      end.to_json
    end

    it do
      expect { subject }.to change(github_install.check_suites, :count).by(0)
        .and change {
               github_check_suite.reload.pull_requests_data
             }
        .and have_enqueued_job(Github::CheckSuites::RequestedJob).with(github_check_suite)
    end
  end
end
