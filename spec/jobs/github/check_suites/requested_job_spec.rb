require "rails_helper"

RSpec.describe Github::CheckSuites::RequestedJob, type: :job do
  let(:github_check_suite) { create(:github_check_suite) }
  let(:instance_class) { described_class.new }
  let(:configuration_service) do
    double(
      :configuration_service,
      custom_configuration_file?: true,
      custom_configuration_valid?: true,
      configuration: Spellcheck::Configuration.new
    )
  end

  let(:pull_request_info_service) do
    double(
      :pull_request_info_service,
      pull_request_user_login: "SampleUser",
      pull_request_user_type: "User"
    )
  end

  before do
    allow_any_instance_of(described_class).to receive(:configuration_service).and_return(configuration_service)
    allow_any_instance_of(described_class).to receive(:pull_request_info_service).and_return(pull_request_info_service)
  end

  describe "::perform_now" do
    subject { described_class.perform_now(github_check_suite) }

    context "check suite throws an Octokit::NotFound error - We can't access the code" do
      before do
        allow(configuration_service).to receive(:configuration).and_raise(Octokit::NotFound)
      end

      it { expect { subject }.to change(github_check_suite, :conclusion_failure?).from(false).to(true) }
    end
  end

  describe "#perform" do
    subject { instance_class.perform(github_check_suite) }

    context "check suite isn't analysable" do
      let(:github_check_suite) { create(:github_check_suite, :not_analysable) }

      it { expect { subject }.to change(github_check_suite, :conclusion_skipped?).from(false).to(true) }

      it "Does not queue up update github job" do
        expect { subject }.not_to have_enqueued_job(Heroku::RunCommandJob)
      end
    end

    context "check suite is a pull request fork made by a bot" do
      let(:github_check_suite) { create(:github_check_suite, :pr_on_fork_repo) }
      let(:pull_request_info_service) do
        double(
          :pull_request_info_service,
          pull_request_user_login: "SampleUser",
          pull_request_user_type: "Bot"
        )
      end

      it { expect { subject }.to change { github_check_suite.reload.conclusion_skipped? }.from(false).to(true) }
      it { expect { subject }.to change { github_check_suite.reload.pull_request_user_login }.to("SampleUser") }
      it { expect { subject }.to change { github_check_suite.reload.pull_request_user_type }.to("Bot") }

      it "Does not queue up AnalysisJob" do
        expect do
          subject
        end.not_to have_enqueued_job(Heroku::RunCommandJob).with("Github::CheckSuites::AnalysisJob", github_check_suite)
      end
    end

    context "check suite is analysable, but is on a private repo & the current plan doesn't support that" do
      let(:github_check_suite) { create(:github_check_suite, :not_analysable_as_plan_does_not_support_private) }

      it { expect { subject }.to change { github_check_suite.reload.conclusion_skipped? }.from(false).to(true) }

      it "Does not queue up AnalysisJob" do
        expect do
          subject
        end.not_to have_enqueued_job(Heroku::RunCommandJob).with("Github::CheckSuites::AnalysisJob", github_check_suite)
      end

      it "Sets the check_suite#conclusion_skipped_reason to private_repositories_not_supported" do
        expect { subject }.to change { github_check_suite.reload.conclusion_skipped_reason }
          .from("none").to("private_repositories_not_supported")
      end

      it "Queues up SkipReasonUpdateRemoteJob" do
        expect { subject }.to have_enqueued_job(Github::CheckSuites::SkipReasonUpdateRemoteJob).with(github_check_suite)
      end
    end

    context "saves data about the commit & the configuration we should use" do
      it { expect { subject }.to change(github_check_suite, :custom_configuration_file).from(false) }
      it { expect { subject }.to change(github_check_suite, :custom_configuration_valid).from(false) }
      it { expect { subject }.to change(github_check_suite, :custom_configuration).from({}) }
    end

    context "Queues up the job to update GitHub" do
      it do
        expect do
          subject
        end.to have_enqueued_job(Heroku::RunCommandJob).with("Github::CheckSuites::AnalysisJob", github_check_suite)
      end
    end
  end
end
