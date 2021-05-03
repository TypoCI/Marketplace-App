require "rails_helper"

RSpec.describe Spellcheck::Word do
  let(:configuration) { nil }
  let(:instance_class) { described_class.new(word, configuration: configuration) }
  let(:word) { "valid" }

  describe "#valid?" do
    subject { instance_class.valid? }

    %w[valid Word List PickleTime ab a Pickleable APPLE SSLCertificated mingw defp rfc itemprop noscript strtolower accessor tfjsVersion react todo logout tsx async react-router actionmailbox Vitor vue vuejs auth https transactional uncomment gbp eur gdpr anonymizing jqueryui
      ip's].each do |valid_word|
      let(:configuration) { Spellcheck::Configuration.new(dictionaries: ["en"]) }
      context "Word is #{valid_word}" do
        let(:word) { valid_word }

        it { is_expected.to eq(true) }
      end
    end

    %w[MathedName Rickle recieve entwickler vitor].each do |invalid_word|
      context "Word is #{invalid_word}" do
        let(:word) { invalid_word }

        it { is_expected.to eq(false) }
      end
    end

    context "Word contains non UTF-8 letter & needs to be parsed into ISO-8859-1" do
      let(:configuration) { Spellcheck::Configuration.new(dictionaries: ["pt_BR"]) }
      let(:word) { "waɪ" }

      it { is_expected.to eq(false) }
    end

    context "de dictionary" do
      let(:configuration) { Spellcheck::Configuration.new(dictionaries: ["de"]) }

      %w[entwickler].each do |valid_word|
        context "Word is #{valid_word}" do
          let(:word) { valid_word }

          it { is_expected.to eq(true) }
        end
      end

      %w[cracking].each do |invalid_word|
        context "Invalid is #{invalid_word}" do
          let(:word) { invalid_word }

          it { is_expected.to eq(false) }
        end
      end
    end
  end

  describe "#suggestion" do
    subject { instance_class.suggestion }

    context 'Word is "recieve"' do
      let(:word) { "recieve" }

      it { is_expected.to eq("receive") }
    end

    context 'Word is "UAdjdjdjdK"' do
      let(:word) { "UAdjdjdjdK" }

      it { is_expected.to eq('U¯\\_(ツ)_/¯K') }
    end

    context 'Word is "Recieve"' do
      let(:word) { "Recieve" }

      it { is_expected.to eq("Receive") }
    end

    context 'Word is "MathedName"' do
      let(:word) { "MathedName" }

      it { is_expected.to eq("MatedName") }
    end

    context 'Word is "text-centera"' do
      let(:word) { "text-centera" }

      it { is_expected.to eq("text-centare") }
    end

    context "Word contains non UTF-8 letter & needs to be parsed into ISO-8859-1" do
      let(:configuration) { Spellcheck::Configuration.new(dictionaries: ["pt_BR"]) }
      let(:word) { "appbundleɪ" }

      it { is_expected.to eq("appbundle") }
    end
  end
end
