require 'rails_helper'

RSpec.describe Github::CheckSuites::AnalysisService do
  let(:github_check_suite) { build(:github_check_suite) }
  let(:instance_class) { described_class.new(github_check_suite) }
  let(:pull_request_files_with_spelling_error) do
    [
      {
        sha: '4ca8b22f48892f0194d4dc8d99cbfb1097838a62',
        filename: 'source/blog/2019-09-26-intraducing-typo-ci.html.md',
        status: 'added',
        additions: 18,
        deletions: 0,
        changes: 18,
        blob_url: 'https://github.com/MikeRogers0/MikeRogersIO/blob/47283dd20039d58e7cc59ba102959c1668772955/source/blog/2019-09-26-intraducing-typo-ci.html.md',
        raw_url: 'https://github.com/MikeRogers0/MikeRogersIO/raw/47283dd20039d58e7cc59ba102959c1668772955/source/blog/2019-09-26-intraducing-typo-ci.html.md',
        contents_url: 'https://api.github.com/repos/MikeRogers0/MikeRogersIO/contents/source/blog/2019-09-26-intraducing-typo-ci.html.md?ref=47283dd20039d58e7cc59ba102959c1668772955',
        patch: "@@ -0,0 +1,18 @@\n" +
          "+---\n" +
          "+layout: post\n" +
          '+ - MathedMan'
      }
    ]
  end
  let(:github_install_service) do
    double :github_install_service,
           get_pull_request_files: pull_request_files_with_spelling_error,
           get_pull_request_commits: [],
           commit: {},
           compare: { commits: [] }
  end
  let(:configuration) { Spellcheck::Configuration.new }

  before { allow(instance_class).to receive(:github_install_service).and_return(github_install_service) }

  describe '#annotations' do
    subject { instance_class.annotations }

    before { allow(instance_class).to receive(:configuration).and_return(configuration) }

    context 'one file' do
      it { is_expected.not_to eq([]) }
    end

    context 'CheckSuite has no pull request associated to it' do
      let(:github_check_suite) { build(:github_check_suite, :no_pull_requests) }
      let(:github_install_service) do
        double :github_install_service, compare: { files: pull_request_files_with_spelling_error }
      end

      it { is_expected.not_to eq([]) }
    end
  end

  describe '#invalid_words' do
    subject { instance_class.invalid_words }

    before { allow(instance_class).to receive(:configuration).and_return(configuration) }

    context 'one file' do
      it { is_expected.to eq(%w[intraducing MathedMan]) }
    end
  end

  describe '#conclusion' do
    subject { instance_class.conclusion }

    context 'no spelling errors' do
      before { allow(instance_class).to receive(:annotations).and_return([]) }

      it { is_expected.to eq('success') }
    end

    context 'One spelling error' do
      before { allow(instance_class).to receive(:annotations).and_return([{ some_error: true }]) }

      it { is_expected.to eq('neutral') }
    end

    context 'custom configuration file is invalid' do
      let(:github_check_suite) do
        build(:github_check_suite, custom_configuration_file: true, custom_configuration_valid: false)
      end

      it { is_expected.to eq('action_required') }
    end
  end

  describe '#files_analysed_count' do
    subject { instance_class.files_analysed_count }

    before { allow(instance_class).to receive(:files).and_return([{ one_file: true }]) }

    it { is_expected.to eq(1) }
  end

  describe '#spelling_mistakes_count' do
    subject { instance_class.spelling_mistakes_count }

    before { allow(instance_class).to receive(:annotations).and_return([{ one_error: true }, { two_error: true }]) }

    it { is_expected.to eq(2) }
  end

  describe '#file_name_extensions' do
    subject { instance_class.file_name_extensions }

    let(:pull_request_files_with_spelling_error) do
      [
        {
          sha: '4ca8b22f48892f0194d4dc8d99cbfb1097838a62',
          filename: 'source/blog/2019-09-26-intraducing-typo-ci.html.md',
          status: 'added',
          additions: 18,
          deletions: 0,
          changes: 18,
          blob_url: 'https://github.com/MikeRogers0/MikeRogersIO/blob/47283dd20039d58e7cc59ba102959c1668772955/source/blog/2019-09-26-intraducing-typo-ci.html.md',
          raw_url: 'https://github.com/MikeRogers0/MikeRogersIO/raw/47283dd20039d58e7cc59ba102959c1668772955/source/blog/2019-09-26-intraducing-typo-ci.html.md',
          contents_url: 'https://api.github.com/repos/MikeRogers0/MikeRogersIO/contents/source/blog/2019-09-26-intraducing-typo-ci.html.md?ref=47283dd20039d58e7cc59ba102959c1668772955',
          patch: "@@ -0,0 +1,18 @@\n" +
            "+---\n" +
            "+layout: post\n" +
            '+ - MathedMan'
        },
        {
          sha: '4ca8b22f48892f0194d4dc8d99cbfb1097838a62',
          filename: 'source/style.css',
          status: 'added',
          additions: 18,
          deletions: 0,
          changes: 18,
          blob_url: 'https://github.com/MikeRogers0/MikeRogersIO/blob/47283dd20039d58e7cc59ba102959c1668772955/source/style.css',
          raw_url: 'https://github.com/MikeRogers0/MikeRogersIO/raw/47283dd20039d58e7cc59ba102959c1668772955/source/style.css',
          contents_url: 'https://api.github.com/repos/MikeRogers0/MikeRogersIO/contents/source/style.css?ref=47283dd20039d58e7cc59ba102959c1668772955',
          patch: "@@ -0,0 +1,18 @@\n" +
            "+---\n" +
            "+layout: post\n" +
            '+ - MathedMan'
        },

        {
          filename: 'Gemfile',
          status: 'added',
          additions: 18,
          deletions: 0,
          changes: 18,
          blob_url: 'https://github.com/MikeRogers0/MikeRogersIO/blob/47283dd20039d58e7cc59ba102959c1668772955/Gemfile',
          raw_url: 'https://github.com/MikeRogers0/MikeRogersIO/raw/47283dd20039d58e7cc59ba102959c1668772955/Gemfile',
          contents_url: 'https://api.github.com/repos/MikeRogers0/MikeRogersIO/contents/Gemfile?ref=47283dd20039d58e7cc59ba102959c1668772955',
          patch: "@@ -0,0 +1,18 @@\n" +
            "+---\n" +
            "+layout: post\n" +
            '+ - MathedMan'
        }
      ]
    end

    it { is_expected.to eq(%w[md css]) }
  end
end
