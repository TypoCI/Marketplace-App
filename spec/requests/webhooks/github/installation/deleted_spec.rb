require 'rails_helper'

describe 'Webhooks - Github - Installation - deleted', type: :request do
  subject do
    post_github_webhook(request_body, headers)
  end

  let(:headers) do
    {
      CONTENT_TYPE: 'application/json',
      HTTP_X_GITHUB_EVENT: 'installation'
    }
  end

  let!(:github_install) { create(:github_install) }

  let(:request_body) do
    JSON.parse(Rails.root.join('spec', 'fixtures', 'files', 'webhooks', 'github', 'installation',
                               'deleted.json').read).tap do |json|
      json['installation']['id'] = github_install.install_id
    end.to_json
  end

  it do
    expect { subject }.to have_enqueued_job(Github::Installation::IncinerationJob).with(github_install)
  end

  context 'Install has check suites' do
    let(:github_install) { create(:github_install, :with_check_suite) }

    it do
      expect { subject }.to have_enqueued_job(Github::Installation::IncinerationJob).with(github_install)
    end
  end
end
