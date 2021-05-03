require 'rails_helper'

RSpec.describe Github::CheckSuites::IncinerationJob, type: :job do
  let(:github_install) { create(:github_install) }
  let(:instance_class) { described_class.new }

  describe '#perform' do
    subject { instance_class.perform }

    let!(:old_check_suite) do
      create(:github_check_suite, install: github_install, created_at: (Time.zone.now - 22.days))
    end
    let!(:new_check_suite) { create(:github_check_suite, install: github_install) }

    it 'Deletes data older then 3 weeks (21 days)' do
      expect { subject }.to change { Github::CheckSuite.find_by(id: old_check_suite.id) }.from(old_check_suite).to(nil)
    end

    it 'Does not delete fresher records' do
      expect { subject }.not_to(change { Github::CheckSuite.find_by(id: new_check_suite.id) })
    end
  end
end
