require 'rails_helper'

RSpec.describe Github::Install, type: :model do
  let(:instance) { described_class.new }

  describe '::where_account_is_an_organisation_or_for_user' do
    subject { described_class.account_is_an_organization_or_for_user_with_uid('12345') }

    let!(:user_install) { create(:github_install, account_id: '12345') }
    let!(:other_user_install) { create(:github_install) }
    let!(:organization_install) { create(:github_install, :organization) }

    it do
      expect(subject).to include(user_install)
      expect(subject).to include(organization_install)
      expect(subject).not_to include(other_user_install)
    end
  end

  describe '#plan' do
    subject { instance.plan }

    context 'without a known plan' do
      let(:instance) { build(:github_install) }

      context 'fallback to early bird plan' do
        it { expect(subject.title).to eq('Trial') }
      end
    end

    context 'with a known plan' do
      let(:instance) { build(:github_install, :with_plan) }

      context 'loads that plan from GitHub::Plan array' do
        it { expect(subject.title).to eq('Organization') }
      end
    end
  end
end
