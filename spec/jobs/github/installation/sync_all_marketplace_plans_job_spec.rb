require "rails_helper"

RSpec.describe Github::Installation::SyncAllMarketplacePlansJob, type: :job do
  let(:github_install) { create(:github_install) }
  let(:instance_class) { described_class.new }
  let(:github_app_service_client) { double :github_app_service_client }
  let(:plan) { OpenStruct.new(id: 4756) }
  let(:marketplace_plan) do
    {
      url: "https://api.github.com/users/#{github_install.account_login}",
      type: "User",
      id: github_install.account_id,
      login: github_install.account_login,
      email: nil,
      marketplace_pending_change: nil,
      marketplace_purchase: {
        billing_cycle: "monthly",
        unit_count: 1,
        on_free_trial: false,
        free_trial_ends_on: nil,
        is_installed: true,
        updated_at: Time.zone.today,
        next_billing_date: nil,
        plan: {
          url: "https://api.github.com/marketplace_listing/plans/4756",
          accounts_url: "https://api.github.com/marketplace_listing/plans/4756/accounts",
          id: 4756,
          number: 1,
          name: "Free",
          description: "Unlimited users. Unlimited repos. Unlimited spell checks.",
          monthly_price_in_cents: 0,
          yearly_price_in_cents: 0,
          price_model: "FREE",
          has_free_trial: false,
          unit_name: nil,
          state: "published",
          bullets: ["Unlimited users", "Unlimited repos", "Unlimited spell checks"]
        }
      }
    }
  end

  describe "#perform" do
    subject { instance_class.perform }

    it do
      allow(instance_class).to receive(:github_app_service_client).and_return(github_app_service_client)
      expect(github_app_service_client).to receive(:list_plans).and_return([plan])
      expect(github_app_service_client).to receive(:list_accounts_for_plan).with(4756).and_return([marketplace_plan])

      expect { subject }.to have_enqueued_job(Github::Installation::UpdateMarketplacePurchaseJob).with(github_install)
    end
  end
end
