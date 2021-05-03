require 'rails_helper'

describe 'Webhooks - Github - Marketplace Purchase - changed', type: :request do
  subject do
    post_github_webhook(request_body, headers)
  end

  let(:headers) do
    {
      CONTENT_TYPE: 'application/json',
      HTTP_X_GITHUB_EVENT: 'marketplace_purchase'
    }
  end

  let!(:github_install) { create(:github_install) }

  let(:request_body) do
    JSON.parse(Rails.root.join('spec', 'fixtures', 'files', 'webhooks', 'github', 'marketplace_purchase',
                               'changed.json').read).tap do |json|
      json['marketplace_purchase']['account']['id'] = github_install.account_id
    end.to_json
  end

  it do
    expect(Github::Installation::UpdateMarketplacePurchaseJob).to receive(:perform_later).with(github_install)
    subject
  end
end
