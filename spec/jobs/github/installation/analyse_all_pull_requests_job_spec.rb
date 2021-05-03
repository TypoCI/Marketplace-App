require "rails_helper"

RSpec.describe Github::Installation::AnalyseAllPullRequestsJob, type: :job do
  let(:github_install) { create(:github_install) }
  let(:instance_class) { described_class.new }
  let(:github_install_service) { double :github_install_service }
  let(:repository) do
    {
      id: 11_435_930,
      node_id: "MDEwOlJlcG9zaXRvcnkxMTQzNTkzMA==",
      name: "MikeRogersIO",
      full_name: "MikeRogers0/MikeRogersIO",
      private: false,
      fork: false,
      stargazers_count: 7,
      watchers_count: 7,
      open_issues_count: 3,
      license: nil,
      forks: 1,
      open_issues: 3,
      watchers: 7,
      default_branch: "master"
    }
  end

  describe "#perform" do
    subject { instance_class.perform(github_install) }

    it do
      allow(instance_class).to receive(:github_install_service).and_return(github_install_service)
      expect(github_install_service).to receive(:list_repositories).and_return([repository])
      expect(Github::Repository::AnalysePullRequestsJob).to receive(:perform_later).once
      subject
    end
  end
end
