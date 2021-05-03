require "rails_helper"

RSpec.describe Github::CheckSuites::AnalysisJob, type: :job do
  let(:github_check_suite) { create(:github_check_suite) }
  let(:instance_class) { described_class.new }
  let(:analysis_service) do
    double(
      :analysis_service,
      conclusion: "success",
      annotations: [],
      invalid_words: [],
      files_analysed_count: 0,
      spelling_mistakes_count: 0,
      file_name_extensions: ["css"]
    )
  end
  let(:github_install_service) { double :github_install_service }

  before do
    allow_any_instance_of(described_class).to receive(:analysis_service).and_return(analysis_service)
    allow_any_instance_of(described_class).to receive(:install_service).and_return(github_install_service)
  end

  describe "::perform_later" do
    subject { described_class.perform_later(github_check_suite) }

    context "Commit was on a branch without a Pull Request" do
      let(:github_check_suite) { create(:github_check_suite, :no_pull_requests) }

      it do
        expect { subject }.to have_enqueued_job(described_class)
          .with(github_check_suite)
          .on_queue("github__check_suites__analysis")
      end
    end

    context "Commit was on the default branch" do
      let(:github_check_suite) { create(:github_check_suite, :committed_to_default_branch) }

      it do
        expect { subject }.to have_enqueued_job(described_class)
          .with(github_check_suite)
          .on_queue("github__check_suites__analysis--default_branch")
      end
    end

    context "CheckSuite has Pull Request data" do
      it do
        expect { subject }.to have_enqueued_job(described_class)
          .with(github_check_suite)
          .on_queue("github__check_suites__analysis--pull_request")
      end
    end
  end

  describe "::perform_now" do
    subject { described_class.perform_now(github_check_suite) }

    context "check suite throws an Octokit::InternalServerError error - Where GitHub is having trouble" do
      before do
        allow(analysis_service).to receive(:annotations).and_raise(Octokit::InternalServerError)
      end

      it do
        expect { subject }.to have_enqueued_job(described_class).with(github_check_suite)
      end
    end

    context "check suite throws an Octokit::BadGateway error - Where GitHub is having trouble" do
      before do
        allow(analysis_service).to receive(:annotations).and_raise(Octokit::BadGateway)
      end

      it do
        expect { subject }.to have_enqueued_job(described_class).with(github_check_suite)
      end
    end

    context "check suite throws an Octokit::Unauthorized error - We've lost access, but maybe just temporally" do
      before do
        allow(analysis_service).to receive(:annotations).and_raise(Octokit::Unauthorized)
      end

      it do
        expect { subject }.to have_enqueued_job(described_class).with(github_check_suite)
      end
    end

    context "check suite throws an Faraday::ConnectionFailed error - GitHub is just down again" do
      before do
        allow(analysis_service).to receive(:annotations).and_raise(Faraday::ConnectionFailed, "execution expired")
      end

      it do
        expect { subject }.to have_enqueued_job(described_class).with(github_check_suite)
      end
    end

    context "check suite throws an Octokit::NotFound error - We can't access the code" do
      before do
        allow(analysis_service).to receive(:annotations).and_raise(Octokit::NotFound)
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
        expect { subject }.not_to have_enqueued_job(Github::CheckSuites::UpdateRemoteJob).with(github_check_suite)
      end
    end

    context "saves annotations & analytics about queue time & processing time" do
      it { expect { subject }.to change(github_check_suite, :queuing_duration).from(nil) }
      it { expect { subject }.to change(github_check_suite, :processing_duration).from(nil) }
      it { expect { subject }.to change(github_check_suite, :annotations).from(nil) }
      it { expect { subject }.to change(github_check_suite, :files_analysed_count).from(nil) }
      it { expect { subject }.to change(github_check_suite, :spelling_mistakes_count).from(nil) }
      it { expect { subject }.to change(github_check_suite, :file_name_extensions).from([]) }
    end

    context "Queues up the job to update GitHub" do
      it do
        expect { subject }.to have_enqueued_job(Github::CheckSuites::UpdateRemoteJob).with(github_check_suite)
      end
    end
  end
end
