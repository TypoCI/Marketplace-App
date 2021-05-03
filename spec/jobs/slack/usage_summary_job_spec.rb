require "rails_helper"

RSpec.describe Slack::UsageSummaryJob, type: :job do
  let(:instance_class) { described_class.new }
  let(:client) { double :client }

  before do
    allow(instance_class).to receive(:client).and_return(client)
    create(:github_check_suite, :with_analysis_performed)
  end

  describe "#perform" do
    subject { instance_class.perform }

    it do
      expect(client).to receive(:chat_postMessage).and_return(true)
      expect { subject }.not_to raise_error
    end
  end
end
