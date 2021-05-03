require 'rails_helper'

RSpec.describe Github::Installation::IncinerationJob, type: :job do
  let!(:github_install) { create(:github_install, :with_check_suite) }
  let(:instance_class) { described_class.new }

  describe '#perform' do
    subject { instance_class.perform(github_install) }

    it do
      expect { subject }.to change(Github::Install, :count).from(1).to(0)
                                                           .and change(Github::CheckSuite, :count).from(1).to(0)
    end
  end
end
