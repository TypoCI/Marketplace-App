require 'rails_helper'

RSpec.describe Github::Repositories::FileService do
  let(:instance_class) { Github::Repositories::FileService.new(file, repo_file_path, configuration: nil) }

  describe '#analysable?' do
    subject { instance_class.analysable? }

    context 'binary file' do
      let(:file) { Rails.root.join('app', 'assets', 'images', 'favicon.png').to_s }
      let(:repo_file_path) { 'app/assets/images/favicon.png' }

      it { is_expected.to eq(false) }
    end

    context 'text file' do
      let(:file) { Rails.root.join('README.md').to_s }
      let(:repo_file_path) { 'README.md' }

      it { is_expected.to eq(true) }
    end

    context 'text file without an extension' do
      let(:file) { Rails.root.join('Gemfile').to_s }
      let(:repo_file_path) { 'Gemfile' }

      it { is_expected.to eq(true) }
    end
  end
end
