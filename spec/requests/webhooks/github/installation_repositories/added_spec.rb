require "rails_helper"

describe "Webhooks - Github - InstallationRepositories - Added", type: :request do
  subject do
    post_github_webhook(request_body, headers)
  end

  let!(:github_install) { create(:github_install) }
  let(:headers) do
    {
      CONTENT_TYPE: "application/json",
      HTTP_X_GITHUB_EVENT: "installation_repositories"
    }
  end

  let(:request_body) do
    JSON.parse(Rails.root.join("spec", "fixtures", "files", "webhooks", "github", "installation_repositories",
      "added.json").read).tap do |json|
      json["installation"]["id"] = github_install.install_id
      json["installation"]["app_id"] = github_install.app_id
      json["repositories_added"][0]["full_name"] = "testAccount/sample-repo"
    end.to_json
  end

  context "Install is present in the system" do
    it do
      expect(Github::Installation::UpdateRepositoriesCountJob).to receive(:perform_later).with(github_install)
      expect(Github::Repository::AnalysePullRequestsJob).to receive(:perform_later).with(github_install,
        "testAccount/sample-repo").once
      subject
    end
  end
end
