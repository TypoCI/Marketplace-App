require 'rails_helper'

RSpec.describe Spellcheck::FileName do
  describe '#annotations' do
    subject { described_class.new(filename, configuration: Spellcheck::Configuration.new).annotations }

    let(:filename) { 'source/blog/2019-09-26-intraducing-typo-ci.html.md' }
    let(:expected_annotations) do
      [
        {
          path: 'source/blog/2019-09-26-intraducing-typo-ci.html.md',
          start_line: 1,
          end_line: 1,
          annotation_level: 'warning',
          title: 'Filename: source/blog/2019-09-26-intraducing-typo-ci.html.md',
          message: '"intraducing" in the filename is a typo. Did you mean "introducing"?'
        }
      ]
    end

    it do
      expect(subject).to eq(expected_annotations)
      expect(subject.count).to eq(1)
    end

    context 'filenames without spelling errors' do
      [
        'typo-ci.html.md',
        'something.markdown',
        'Gemfile',
        'app.json',
        'yarn.lock',
        'babel.config.js',
        'postcss.config.js',
        'Rakefile',
        'config.ru',
        'model/file.rb',
        'something.js',
        'app.php',
        'db/schema.rb',
        'file_spec.rb',
        'config/webpack.js',
        'config/credentials.yml.enc',
        'Dockerfile',
        'sample.txt',
        'a-file.sql',
        'python.py',
        'asp.asp',
        'index.html',
        'index.htm',
        'index.xml',
        'index.html.erb',
        'feed.rss',
        'style.css',
        'perl.pl',
        'cgi.cgi',
        'cfm.cfm',
        'shell.sh',
        'visualbasic.vb',
        'c-sharp.cs',
        'cpp.cpp',
        'xml.xml',
        'csv.csv',
        'jsx.jsx',
        'wasm.wasm',
        'vcxproj.vcxproj',
        'xcodeproj.xcodeproj',
        'scss/_alert.scss'
      ].each do |custom_filename|
        context custom_filename do
          let(:filename) { custom_filename }

          it { is_expected.to eq([]) }
        end
      end
    end
  end
end
