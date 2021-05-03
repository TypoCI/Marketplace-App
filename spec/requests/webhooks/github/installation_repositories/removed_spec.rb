require 'rails_helper'

describe 'Webhooks - Github - InstallationRepositories - Removef', type: :request do
  subject do
    post_github_webhook(request_body, headers)
  end

  let!(:github_install) { create(:github_install) }
  let(:headers) do
    {
      CONTENT_TYPE: 'application/json',
      HTTP_X_GITHUB_EVENT: 'installation_repositories'
    }
  end

  let(:request_body) do
    JSON.parse(Rails.root.join('spec', 'fixtures', 'files', 'webhooks', 'github', 'installation_repositories',
                               'removed.json').read).tap do |json|
      json['installation']['id'] = github_install.install_id
      json['installation']['app_id'] = github_install.app_id
    end.to_json
  end

  context 'Install is present in the system' do
    it do
      expect(Github::Installation::UpdateRepositoriesCountJob).to receive(:perform_later).with(github_install)
      subject
    end
  end
end
