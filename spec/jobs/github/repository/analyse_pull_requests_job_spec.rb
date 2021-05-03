require 'rails_helper'

RSpec.describe Github::Repository::AnalysePullRequestsJob, type: :job do
  let(:github_install) { create(:github_install) }
  let(:instance_class) { described_class.new }
  let(:github_install_service) { double :github_install_service }
  let(:github_repository) { 'MikeRogers0/MikeRogersIO' }
  let(:pull_request) do
    {
      url: 'https://api.github.com/repos/MikeRogers0/MikeRogersIO/pulls/58',
      id: 325_606_093,
      node_id: 'MDExOlB1bGxSZXF1ZXN0MzI1NjA2MDkz',
      number: 58,
      state: 'open',
      locked: false,
      title: 'Bump puma and capistrano3-puma',
      user: {},
      body: '',
      created_at: Time.zone.now,
      updated_at: Time.zone.now,
      merge_commit_sha: '50370ccc631b497bbd986d8b39b5e3e16474714a',
      head: {
        label: 'MikeRogers0:dependabot/bundler/puma-and-capistrano3-puma-4.2.1',
        ref: 'dependabot/bundler/puma-and-capistrano3-puma-4.2.1',
        sha: '5765c0a61d5d15b4aca451989d21986ecf84b676',
        user: {},
        repo: { full_name: 'forked-account/MikeRogersIO', default_branch: 'master' }
      },
      base: {
        sha: '50370ccc631b497bbd986d8b39b5e3e16474714a',
        repo: { full_name: 'MikeRogers0/MikeRogersIO', default_branch: 'master', language: 'Ruby' }
      }
    }
  end

  before do
    allow(instance_class).to receive(:github_install_service).and_return(github_install_service)
  end

  describe '#perform' do
    subject { instance_class.perform(github_install, github_repository) }

    it do
      expect(github_install_service).to receive(:list_open_pull_requests).with(github_repository).and_return([pull_request])
      expect(Github::CheckSuites::RequestedJob).to receive(:perform_later).once
      expect { subject }.to change(Github::CheckSuite, :count).from(0).to(1)
    end

    context 'PR is older then 1 months' do
      let(:pull_request_really_old) do
        pull_request.tap do |pr_hash|
          pr_hash[:updated_at] = 1.month.ago
        end
      end

      it do
        expect(github_install_service).to receive(:list_open_pull_requests).with(github_repository).and_return([pull_request_really_old])
        expect(Github::CheckSuites::RequestedJob).not_to receive(:perform_later)
        expect { subject }.not_to change(Github::CheckSuite, :count)
      end
    end

    context 'head repo was deleted, but PR is still open' do
      let(:pull_request_missing_head) do
        pull_request.tap do |pr_hash|
          pr_hash[:head][:repo] = nil
        end
      end

      it do
        expect(github_install_service).to receive(:list_open_pull_requests).with(github_repository).and_return([pull_request_missing_head])
        expect(Github::CheckSuites::RequestedJob).not_to receive(:perform_later)
        expect { subject }.not_to change(Github::CheckSuite, :count)
      end
    end
  end
end
