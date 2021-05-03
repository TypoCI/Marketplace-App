require 'rails_helper'

RSpec.describe Github::CheckSuites::UpdateRemoteJob, type: :job do
  let(:github_check_suite) { create(:github_check_suite, :analysed_no_typos) }
  let(:instance_class) { described_class.new }
  let(:github_install_service) { double :github_install_service }

  before do
    allow_any_instance_of(described_class).to receive(:install_service).and_return(github_install_service)
    instance_class.github_check_suite = github_check_suite
  end

  describe '#perform' do
    subject { instance_class.perform(github_check_suite) }

    context 'With >50 annotations' do
      let(:annotations) do
        149.times.collect do |nth|
          { annotation_level: :warning, body: nth }
        end
      end

      it do
        expect(github_check_suite).to receive(:annotations).and_return(annotations)
        expect(instance_class).to receive(:create_check_run_on_github!).and_return(true)

        # Only seen twice because first 50 is in create_check_run_on_github call
        expect(github_install_service).to receive(:update_check_run).twice

        subject
      end
    end
  end

  describe '#output_title' do
    subject { instance_class.output_title }

    context 'no spelling errors' do
      before do
        github_check_suite.spelling_mistakes_count = 0
      end

      it { is_expected.to eq('No typos found') }
    end

    context 'One spelling error' do
      before do
        github_check_suite.spelling_mistakes_count = 1
      end

      it { is_expected.to eq('Found a typo') }
    end

    context 'two spelling errors' do
      before do
        github_check_suite.spelling_mistakes_count = 2
      end

      it { is_expected.to eq('Found a few typos') }
    end

    context 'custom configuration file is invalid' do
      before do
        github_check_suite.custom_configuration_file = true
        github_check_suite.custom_configuration_valid = false
      end

      it { is_expected.to eq('.typo-ci.yml file is invalid') }
    end
  end

  describe '#output_summary_actions' do
    subject { instance_class.send(:output_summary_actions) }

    it { is_expected.to include('Have a suggestion or feedback for Typo CI?') }

    context 'custom configuration file is invalid' do
      before do
        github_check_suite.custom_configuration_file = true
        github_check_suite.custom_configuration_valid = false
      end

      it {
        expect(subject).to include('**Action Required:** We were unable to parse your `.typo-ci.yml` file. Please review')
      }
    end
  end

  describe '#output_summary_body' do
    subject { instance_class.send(:output_summary_body) }

    context 'no spelling errors in one file' do
      before do
        github_check_suite.files_analysed_count = 1
        github_check_suite.spelling_mistakes_count = 0
      end

      it { is_expected.to eq('Perfect! No typos found in **1 file**') }
    end

    context 'One spelling error in one file' do
      before do
        github_check_suite.files_analysed_count = 1
        github_check_suite.spelling_mistakes_count = 1
      end

      it { is_expected.to eq('**1 typo** found in **1 file**') }
    end

    context 'two spelling errors in one file' do
      before do
        github_check_suite.files_analysed_count = 1
        github_check_suite.spelling_mistakes_count = 2
      end

      it { is_expected.to eq('**2 typos** found in **1 file**') }
    end

    context 'two spelling errors in two files' do
      before do
        github_check_suite.files_analysed_count = 2
        github_check_suite.spelling_mistakes_count = 2
      end

      it { is_expected.to eq('**2 typos** found in **2 files**') }
    end
  end

  describe '#actions' do
    subject { instance_class.actions }

    let(:response) { [] }

    it { is_expected.to eq(response) }
  end

  describe '#check_run_name' do
    subject { instance_class.check_run_name }

    it { is_expected.to eq('TypoCheck (Test)') }
  end
end
