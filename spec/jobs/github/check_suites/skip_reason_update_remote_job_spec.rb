require "rails_helper"

RSpec.describe Github::CheckSuites::SkipReasonUpdateRemoteJob, type: :job do
  let(:github_check_suite) do
    create(:github_check_suite, :not_analysable_as_plan_does_not_support_private, :skipped_because_its_on_wrong_plan)
  end
  let(:instance_class) { described_class.new }
  let(:github_install_service) { double :github_install_service }
  let(:create_check_run) { double :github_install_service, id: 1 }

  before do
    allow(instance_class).to receive(:install_service).and_return(github_install_service)
  end

  describe "#perform" do
    subject { instance_class.perform(github_check_suite) }

    it do
      expect(github_install_service).to receive(:create_check_run)
        .with(github_check_suite.repository_full_name, "TypoCheck (Test)", github_check_suite.head_sha, instance_of(Hash))
        .and_return(create_check_run)
      subject
    end
  end
end
