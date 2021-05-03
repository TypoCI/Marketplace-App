require 'rails_helper'

RSpec.describe Spellcheck::Configuration do
  let(:custom_configuration) { {} }
  let(:instance_class) { described_class.new(custom_configuration) }

  describe '#custom_configuration' do
    subject { instance_class.custom_configuration }

    let(:custom_configuration) do
      YAML.safe_load(Rails.root.join('spec', 'fixtures', 'files', '.typo-ci.yml').read)
    end

    it { expect { subject }.not_to raise_error }
  end

  describe '#to_h' do
    subject { instance_class.to_h }

    context 'No overriding variables' do
      it { is_expected.to eq(Spellcheck::Configuration::DEFAULT_VALUES) }
    end

    context 'Invalid custom_configuration' do
      let(:custom_configuration) { { dictionaries: 'a string, not an array' } }

      it { is_expected.to eq(Spellcheck::Configuration::DEFAULT_VALUES) }
    end

    context 'Another invalid configuration' do
      let(:custom_configuration) { '' }

      it { is_expected.to eq(Spellcheck::Configuration::DEFAULT_VALUES) }
    end

    context 'Totally string instead of symbol passed in override' do
      let(:custom_configuration) { { 'dictionaries' => ['en'] } }

      it { expect(subject[:dictionaries]).to eq(['en']) }
    end

    context 'Totally valid override' do
      let(:custom_configuration) { { dictionaries: ['en'] } }

      it { expect(subject[:dictionaries]).to eq(['en']) }
    end

    context 'Updates when new values are added to excluded_words' do
      before do
        instance_class.excluded_words = ['Apple']
        instance_class.excluded_words += ['Pear']
      end

      it { expect(subject[:excluded_words]).to eq(%w[Apple Pear]) }
    end
  end

  describe '#spellcheck_filenames?' do
    subject { instance_class.spellcheck_filenames? }

    it { is_expected.to eq(true) }

    context 'with spellcheck_filenames set to false' do
      let(:custom_configuration) { { spellcheck_filenames: false } }

      it { is_expected.to eq(false) }
    end
  end

  describe '#excluded_word?' do
    subject { instance_class.excluded_word?('unexcluded') }

    it { is_expected.to eq(false) }

    context 'with "unexcluded" as an excluded word' do
      let(:custom_configuration) { { excluded_words: ['unexcluded'] } }

      it { is_expected.to eq(true) }
    end

    context 'with "Unexcluded" as an excluded word' do
      let(:custom_configuration) { { excluded_words: ['Unexcluded'] } }

      it { is_expected.to eq(true) }
    end

    context 'with "Unexcluded" as an excluded word and make it uppercase' do
      let(:custom_configuration) { { excluded_words: ['Unexcluded'] } }

      it { is_expected.to eq(true) }
    end
  end

  describe '#excluded_file?' do
    subject { instance_class.excluded_file?('folder/file.json') }

    it { is_expected.to eq(false) }

    context 'Requesting .typo-ci.yml file' do
      subject { instance_class.excluded_file?('.typo-ci.yml') }

      it { is_expected.to eq(true) }
    end

    context 'with "folder/*" as an excluded file' do
      let(:custom_configuration) { { excluded_files: ['folder/*'] } }

      it { is_expected.to eq(true) }
    end

    context 'with "*.json" as an excluded file' do
      let(:custom_configuration) { { excluded_files: ['*.json'] } }

      it { is_expected.to eq(true) }
    end

    context 'with "*.min.js" as an excluded file' do
      subject { instance_class.excluded_file?('bootstrap.min.js') }

      let(:custom_configuration) { { excluded_files: ['*.min.js'] } }

      it { is_expected.to eq(true) }

      context 'normal JS file' do
        subject { instance_class.excluded_file?('bootstrap.js') }

        it { is_expected.to eq(false) }
      end
    end

    context 'with "folder/file.json" as an excluded file' do
      let(:custom_configuration) { { excluded_files: ['folder/file.json'] } }

      it { is_expected.to eq(true) }
    end

    context 'with Make file as the filename' do
      subject { instance_class.excluded_file?('platforms/android/jni/Android.mk') }

      it { is_expected.to eq(true) }
    end

    context 'with ElixirSchool .typo-ci.yml' do
      subject { instance_class.excluded_file?('.typo-ci.yml') }

      let(:custom_configuration) do
        YAML.safe_load(Rails.root.join('spec', 'fixtures', 'files', '.typo-ci.yml').read)
      end

      it { is_expected.to eq(true) }
    end
  end
end
