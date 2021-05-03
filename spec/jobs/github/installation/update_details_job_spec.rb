require 'rails_helper'

RSpec.describe Github::Installation::UpdateDetailsJob, type: :job do
  let(:github_install) { create(:github_install, account_type: 'WillChange', account_id: 123) }
  let(:instance_class) { described_class.new }
  let(:github_install_service) { double :github_install_service }

  let(:installation) do
    {
      id: github_install.install_id,
      account: {
        login: 'MikeRogers0',
        id: 325_384,
        node_id: 'MDQ6VXNlcjMyNTM4NA==',
        avatar_url: 'https://avatars2.githubusercontent.com/u/320000?v=4',
        gravatar_id: '',
        url: 'https://api.github.com/users/MikeRogers0',
        html_url: 'https://github.com/MikeRogers0',
        followers_url: 'https://api.github.com/users/MikeRogers0/followers',
        following_url: 'https://api.github.com/users/MikeRogers0/following{/other_user}',
        gists_url: 'https://api.github.com/users/MikeRogers0/gists{/gist_id}',
        starred_url: 'https://api.github.com/users/MikeRogers0/starred{/owner}{/repo}',
        subscriptions_url: 'https://api.github.com/users/MikeRogers0/subscriptions',
        organizations_url: 'https://api.github.com/users/MikeRogers0/orgs',
        repos_url: 'https://api.github.com/users/MikeRogers0/repos',
        events_url: 'https://api.github.com/users/MikeRogers0/events{/privacy}',
        received_events_url: 'https://api.github.com/users/MikeRogers0/received_events',
        type: 'User',
        site_admin: false
      },
      repository_selection: 'selected',
      access_tokens_url: 'https://api.github.com/app/installations/6333414/access_tokens',
      repositories_url: 'https://api.github.com/installation/repositories',
      html_url: 'https://github.com/settings/installations/6333414',
      app_id: 41_496,
      app_slug: 'typoci-localdev',
      target_id: 325_384,
      target_type: 'User',
      permissions: {
        checks: 'write',
        contents: 'read',
        metadata: 'read',
        pull_requests: 'read'
      },
      events: %w[check_suite pull_request],
      created_at: Time.zone.now,
      updated_at: Time.zone.now,
      single_file_name: nil
    }
  end

  describe '#perform' do
    subject { instance_class.perform(github_install) }

    before do
      allow(instance_class).to receive(:github_install_service).and_return(github_install_service)
      allow(github_install_service).to receive(:installation).and_return(installation)
    end

    it do
      expect { subject }.to change(github_install, :account_type)
        .and change(github_install, :account_id)
    end
  end
end
