require "rails_helper"

RSpec.describe Spellcheck::WordPart do
  let(:instance_class) { described_class.new(word, configuration: configuration) }
  let(:word) { "madeeup" }
  let(:configuration) do
    Spellcheck::Configuration.new(
      dictionaries: ["en"]
    )
  end

  describe "#valid?" do
    subject { instance_class.valid? }

    it { is_expected.to eq(false) }

    context "compound word" do
      let(:word) { "topbar" }

      it { is_expected.to eq(true) }
    end

    context 'with "madeeup" as an excluded word' do
      let(:configuration) do
        Spellcheck::Configuration.new(
          excluded_words: ["madeeup"]
        )
      end

      it { is_expected.to eq(true) }
    end
  end

  describe "#suggestions" do
    subject { instance_class.suggestions }

    let(:word) { "topbar" }

    it { is_expected.to eq(["top bar", "top-bar", "toolbar"]) }
  end
end
