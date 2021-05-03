require "rails_helper"

describe "Webhooks - Github - Check Suite - requested", type: :request do
  subject do
    post_github_webhook(request_body, headers)
  end

  let(:headers) do
    {
      CONTENT_TYPE: "application/json",
      HTTP_X_GITHUB_EVENT: "check_suite"
    }
  end

  let!(:github_install) { create(:github_install) }

  let(:request_body) do
    JSON.parse(Rails.root.join("spec", "fixtures", "files", "webhooks", "github", "check_suite",
      "requested.json").read).tap do |json|
      json["installation"]["id"] = github_install.install_id
      json["check_suite"]["head_commit"]["timestamp"] = Time.zone.now.iso8601
    end.to_json
  end

  it do
    expect { subject }.to change(github_install.check_suites, :count).by(1)
  end

  context "Timestamp of last commit is older then a month" do
    let(:request_body) do
      JSON.parse(Rails.root.join("spec", "fixtures", "files", "webhooks", "github", "check_suite",
        "requested.json").read).tap do |json|
        json["installation"]["id"] = github_install.install_id
        json["check_suite"]["head_commit"]["timestamp"] = (Time.zone.now - 2.months).iso8601
      end.to_json
    end

    it "is created, but is skipped by default" do
      expect(Github::CheckSuites::RequestedJob).not_to receive(:perform_later)
      expect { subject }.to change(github_install.check_suites, :count).by(0)
    end
  end

  context "With a pull request" do
    let(:request_body) do
      JSON.parse(Rails.root.join("spec", "fixtures", "files", "webhooks", "github", "check_suite",
        "requested_with_pull_requests.json").read).tap do |json|
        json["installation"]["id"] = github_install.install_id
        json["repository"]["default_branch"] = "master"
        json["check_suite"]["head_branch"] = "sample-feature"
        json["check_suite"]["head_commit"]["timestamp"] = Time.zone.now.iso8601
      end.to_json
    end

    it do
      expect(Github::CheckSuites::RequestedJob).not_to receive(:perform_later)
      expect { subject }.to change(github_install.check_suites, :count).by(0)
    end
  end

  context "With a pull request on a different repo" do
    let(:request_body) do
      JSON.parse(Rails.root.join("spec", "fixtures", "files", "webhooks", "github", "check_suite",
        "requested_with_pull_requests.json").read).tap do |json|
        json["installation"]["id"] = github_install.install_id
        json["repository"]["default_branch"] = "master"
        json["check_suite"]["head_branch"] = "sample-feature"
        json["check_suite"]["pull_requests"][0]["base"]["repo"]["url"] = "https://api.github.com/repos/different-repo/MikeRogersIO"
        json["check_suite"]["head_commit"]["timestamp"] = Time.zone.now.iso8601
      end.to_json
    end

    it do
      expect { subject }.to change(github_install.check_suites, :count).from(0).to(1)
        .and have_enqueued_job(Github::CheckSuites::RequestedJob).on_queue(:github__check_suites__requested)
    end
  end

  context "without pull request on different branch" do
    let(:request_body) do
      JSON.parse(Rails.root.join("spec", "fixtures", "files", "webhooks", "github", "check_suite",
        "requested.json").read).tap do |json|
        json["installation"]["id"] = github_install.install_id
        json["repository"]["default_branch"] = "master"
        json["check_suite"]["head_branch"] = "sample-feature"
        json["check_suite"]["head_commit"]["timestamp"] = Time.zone.now.iso8601
      end.to_json
    end

    it do
      expect { subject }.to change(github_install.check_suites, :count).from(0).to(1)
        .and have_enqueued_job(Github::CheckSuites::RequestedJob).on_queue(:github__check_suites__requested)
    end
  end

  context "without pull request on the default branch" do
    let(:request_body) do
      JSON.parse(Rails.root.join("spec", "fixtures", "files", "webhooks", "github", "check_suite",
        "requested.json").read).tap do |json|
        json["installation"]["id"] = github_install.install_id
        json["repository"]["default_branch"] = "default"
        json["check_suite"]["head_branch"] = "default"
        json["check_suite"]["head_commit"]["timestamp"] = Time.zone.now.iso8601
      end.to_json
    end

    it do
      expect { subject }.to change(github_install.check_suites, :count).by(1)
    end
  end
end
