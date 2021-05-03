require 'rails_helper'

describe 'Webhooks - Github - Installation - created', type: :request do
  subject do
    post_github_webhook(request_body, headers)
  end

  let(:headers) do
    {
      CONTENT_TYPE: 'application/json',
      HTTP_X_GITHUB_EVENT: 'installation'
    }
  end

  let(:request_body) do
    Rails.root.join('spec', 'fixtures', 'files', 'webhooks', 'github', 'installation', 'created.json').read
  end

  it do
    expect(Github::Installation::AnalyseAllPullRequestsJob).to receive(:perform_later)
    expect(Github::Installation::UpdateMarketplacePurchaseJob).to receive(:perform_later)
    expect { subject }.to change(Github::Install, :count).from(0).to(1)
                                                         .and change {
                                                                Github::Install.last&.repositories_count
                                                              }.from(nil).to(1)
  end
end
