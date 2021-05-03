require 'rails_helper'

RSpec.describe Github::CheckSuite, type: :model do
  let(:instance_class) { build(:github_check_suite) }

  describe '#analysable?' do
    subject { instance_class.analysable? }

    it { is_expected.to eq(true) }

    context 'the head_branch is set to github pages branch with no previous commit' do
      let(:instance_class) { build(:github_check_suite, :not_analysable) }

      it { is_expected.to eq(false) }
    end

    context 'commit was made by pull[bot]' do
      let(:instance_class) { build(:github_check_suite, :bot_commit) }

      it { is_expected.to eq(false) }
    end

    context 'the head_branch is set to github pages branch with a previous commit' do
      let(:instance_class) do
        build(:github_check_suite, :not_analysable, base_sha: '8f22da3d6c16f3291cd02e18bc40579558383d60')
      end

      it { is_expected.to eq(true) }
    end

    context 'a newer commit exists on this branch from this sender' do
      let(:instance_class) { create(:github_check_suite) }
      let!(:newer_commit) do
        create(:github_check_suite, install: instance_class.install, created_at: (Time.zone.now + 5.minutes))
      end

      it { is_expected.to eq(false) }
    end

    context 'a newer commit exists on a different branch from this sender' do
      let(:instance_class) { create(:github_check_suite) }
      let!(:newer_commit) do
        create(:github_check_suite, install: instance_class.install, head_branch: 'some_other',
                                    created_at: (Time.zone.now + 5.minutes))
      end

      it { is_expected.to eq(true) }
    end
  end

  describe '#pull_request?' do
    subject { instance_class.pull_request? }

    context 'with pull request' do
      it { is_expected.to eq(true) }
    end

    context 'without pull request' do
      let(:instance_class) { build(:github_check_suite, :no_pull_requests) }

      it { is_expected.to eq(false) }
    end
  end

  describe '#conclusion_skipped!' do
    subject { instance_class.conclusion_skipped! }

    let(:instance_class) { create(:github_check_suite) }

    it 'Updates #conclusion to be skipped & #status to be completed' do
      expect { subject }.to change { instance_class.reload.conclusion }.to('skipped')
                                                                       .and change {
                                                                              instance_class.reload.status
                                                                            }.to('completed')
    end
  end
end
