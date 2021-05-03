require 'rails_helper'

RSpec.describe Github::Installation::UpdateMarketplacePurchaseJob, type: :job do
  let(:github_install) { create(:github_install) }
  let(:instance_class) { described_class.new }
  let(:github_install_service) { double :github_install_service }
  let(:marketplace_pending_change) { nil }
  let(:marketplace_plan) do
    {
      url: "https://api.github.com/users/#{github_install.account_login}",
      type: 'User',
      id: github_install.account_id,
      login: github_install.account_login,
      email: nil,
      marketplace_pending_change: marketplace_pending_change,
      marketplace_purchase: {
        billing_cycle: 'monthly',
        unit_count: 1,
        on_free_trial: false,
        free_trial_ends_on: nil,
        is_installed: true,
        updated_at: Time.zone.today,
        next_billing_date: nil,
        plan: {
          url: 'https://api.github.com/marketplace_listing/plans/4756',
          accounts_url: 'https://api.github.com/marketplace_listing/plans/4756/accounts',
          id: 4756,
          number: 1,
          name: 'Free',
          description: 'Unlimited users. Unlimited repos. Unlimited spell checks.',
          monthly_price_in_cents: 0,
          yearly_price_in_cents: 0,
          price_model: 'FREE',
          has_free_trial: false,
          unit_name: nil,
          state: 'published',
          bullets: ['Unlimited users', 'Unlimited repos', 'Unlimited spell checks']
        }
      }
    }
  end

  describe '#perform' do
    subject { instance_class.perform(github_install) }

    before do
      allow(instance_class).to receive(:github_install_service).and_return(github_install_service)
      allow(github_install_service).to receive(:marketplace_plan).and_return(marketplace_plan)
    end

    it do
      expect { subject }.to change(github_install, :plan_id).from(nil).to(4756)
    end

    context 'marketplace_pending_change contains an upgrade' do
      let(:github_install) { create(:github_install, plan_id: 4756) }
      let(:marketplace_pending_change) do
        {
          plan: {
            id: 4978,
            name: 'Individual'
          },
          effective_date: Time.zone.now + 2.days
        }
      end

      it do
        expect { subject }.to change(github_install, :plan_id).from(4756).to(4978)
      end
    end

    context 'marketplace_pending_change contains a downgrade' do
      let(:github_install) { create(:github_install, plan_id: 4756) }
      let(:marketplace_pending_change) do
        {
          plan: {
            id: 4980,
            name: 'Open Source'
          },
          effective_date: Time.zone.now + 2.days
        }
      end

      it do
        expect { subject }.not_to change(github_install, :plan_id)
      end
    end

    context 'when no marketplace purchase exists' do
      let(:marketplace_plan) { {} }

      it do
        allow(instance_class).to receive(:github_install_service).and_return(github_install_service)
        expect(github_install_service).to receive(:marketplace_plan).and_return(marketplace_plan)

        expect { subject }.not_to change(github_install, :attributes)
      end
    end
  end
end
