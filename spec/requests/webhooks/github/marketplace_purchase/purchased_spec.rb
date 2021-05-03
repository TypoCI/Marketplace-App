require 'rails_helper'

describe 'Webhooks - Github - Marketplace Purchase - purchased', type: :request do
  subject do
    post_github_webhook(request_body, headers)
  end

  let(:headers) do
    {
      CONTENT_TYPE: 'application/json',
      HTTP_X_GITHUB_EVENT: 'marketplace_purchase'
    }
  end

  context 'Without install present in the system' do
    let(:request_body) do
      JSON.parse(Rails.root.join('spec', 'fixtures', 'files', 'webhooks', 'github', 'marketplace_purchase',
                                 'purchased.json').read).to_json
    end

    it do
      expect(Github::Installation::UpdateMarketplacePurchaseJob).not_to receive(:perform_later)
      subject
    end
  end

  context 'With install present in the system' do
    let!(:github_install) { create(:github_install) }

    let(:request_body) do
      JSON.parse(Rails.root.join('spec', 'fixtures', 'files', 'webhooks', 'github', 'marketplace_purchase',
                                 'purchased.json').read).tap do |json|
        json['marketplace_purchase']['account']['id'] = github_install.account_id
      end.to_json
    end

    it do
      expect(Github::Installation::UpdateMarketplacePurchaseJob).to receive(:perform_later).with(github_install)
      subject
    end
  end
end
