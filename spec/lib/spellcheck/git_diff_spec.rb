require "rails_helper"

RSpec.describe Spellcheck::GitDiff do
  let(:path) { "spec/fixtures/files/ruby_sample.rb" }
  let(:patch) do
    "@@ -0,0 +1,18 @@\n" \
      "+---\n" \
      "+layout: post\n" \
      "+ - MathedMan"
  end

  describe "#annotations" do
    subject { described_class.new(patch, path: path, configuration: Spellcheck::Configuration.new).annotations }

    let(:expected_response) do
      [{
        annotation_level: "warning",
        end_column: 13,
        end_line: 3,
        message: '"MathedMan" is a typo. Did you mean "MatedMan"?',
        path: "spec/fixtures/files/ruby_sample.rb",
        start_column: 4,
        start_line: 3,
        title: "MathedMan"
      }]
    end

    it { is_expected.to eq(expected_response) }

    context "misspelling repeated in part of word" do
      let(:patch) do
        "@@ -0,0 +1,18 @@\n" \
          "+---\n" \
          "+based\n" \
          "+ ase"
      end

      let(:expected_response) do
        [
          {
            path: "spec/fixtures/files/ruby_sample.rb",
            start_line: 3,
            end_line: 3,
            start_column: 2,
            end_column: 5,
            annotation_level: "warning",
            title: "ase",
            message: '"ase" is a typo. Did you mean "ache"?'
          }
        ]
      end

      it { is_expected.to eq(expected_response) }
    end
  end

  describe "#message(invalid_word)" do
    subject do
      described_class.new(patch, path: path, configuration: Spellcheck::Configuration.new).send(:message, invalid_word)
    end

    context "Invalid word is: pritty" do
      let(:invalid_word) { Spellcheck::Word.new("pritty") }

      it { is_expected.to eq('"pritty" is a typo. Did you mean "pretty"?') }
    end

    context "Invalid word is: recieve" do
      let(:invalid_word) { Spellcheck::Word.new("recieve") }

      it {
        expect(subject).to eq("\"recieve\" is a typo. Did you mean \"receive\"? I remember this with the rhyme \"I before E, except after C unless it's one of 923 words spelled cie\".")
      }
    end

    context "Invalid word is: Samesies" do
      let(:invalid_word) { Spellcheck::Word.new("Samesies") }

      it {
        expect(subject).to eq("I don't know this word. \"Samesies\"? From context, I believe it means \"Proudly Uneducated\".")
      }
    end
  end
end
