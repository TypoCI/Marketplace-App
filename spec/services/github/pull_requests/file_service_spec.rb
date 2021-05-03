require "rails_helper"

RSpec.describe Github::PullRequests::FileService do
  let(:file_hash) do
    {
      sha: "4ca8b22f48892f0194d4dc8d99cbfb1097838a62",
      filename: "source/blog/2019-09-26-intraducing-typo-ci.html.md",
      status: "added",
      additions: 18,
      deletions: 0,
      changes: 18,
      blob_url: "https://github.com/MikeRogers0/MikeRogersIO/blob/47283dd20039d58e7cc59ba102959c1668772955/source/blog/2019-09-26-intraducing-typo-ci.html.md",
      raw_url: "https://github.com/MikeRogers0/MikeRogersIO/raw/47283dd20039d58e7cc59ba102959c1668772955/source/blog/2019-09-26-intraducing-typo-ci.html.md",
      contents_url: "https://api.github.com/repos/MikeRogers0/MikeRogersIO/contents/source/blog/2019-09-26-intraducing-typo-ci.html.md?ref=47283dd20039d58e7cc59ba102959c1668772955",
      patch: "@@ -0,0 +1,18 @@\n" \
        "+---\n" \
        "+layout: post\n" \
        "+ - MathedMan"
    }
  end
  let(:repo) { "MikeRogers0/MikeRogersIO" }
  let(:head_sha) { "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" }

  let(:configuration) { nil }
  let(:described_instance) do
    described_class.new(file_hash, repo: repo, head_sha: head_sha, configuration: configuration)
  end

  describe "#analysable?" do
    subject { described_instance.analysable? }

    it { is_expected.to eq(true) }

    context "status is not added or modified" do
      let(:file_hash) { {status: "removed"} }

      it { is_expected.to eq(false) }
    end

    context "file path is excluded" do
      let(:configuration) { Spellcheck::Configuration.new(excluded_files: ["source/**.html.md"]) }

      it { is_expected.to eq(false) }
    end
  end

  describe "#filename" do
    subject { described_instance.filename }

    it { is_expected.to eq("source/blog/2019-09-26-intraducing-typo-ci.html.md") }
  end

  describe "#file_name_extension" do
    subject { described_instance.file_name_extension }

    it { is_expected.to eq("md") }
  end

  describe "#analysable_contents?" do
    subject { described_instance.analysable_contents? }

    it { is_expected.to eq(true) }

    context "without a patch diff" do
      let(:file_hash) { {} }

      it { is_expected.to eq(false) }
    end
  end

  describe "#file_name_annotations" do
    subject { described_instance.file_name_annotations }

    let(:file_name_annotations) do
      [{
        path: "source/blog/2019-09-26-intraducing-typo-ci.html.md",
        start_line: 1,
        end_line: 1,
        annotation_level: "warning",
        title: "Filename: source/blog/2019-09-26-intraducing-typo-ci.html.md",
        message: '"intraducing" in the filename is a typo. Did you mean "introducing"?'
      }]
    end

    it { is_expected.to eq(file_name_annotations) }

    context "Configuration#spellcheck_filenames? is set to false" do
      let(:configuration) { Spellcheck::Configuration.new(spellcheck_filenames: false) }

      it { is_expected.to eq([]) }
    end
  end

  describe "#contents_annotations" do
    subject { described_instance.contents_annotations }

    let(:contents_annotations) do
      [{
        path: "source/blog/2019-09-26-intraducing-typo-ci.html.md",
        start_line: 3,
        end_line: 3,
        start_column: 4,
        end_column: 13,
        annotation_level: "warning",
        title: "MathedMan",
        message: '"MathedMan" is a typo. Did you mean "MatedMan"?'
      }]
    end

    it { is_expected.to eq(contents_annotations) }
  end

  describe "#annotations" do
    subject { described_instance.annotations }

    before do
      expect(described_instance).to receive(:file_name_annotations).and_return([{file_name_annotations: true}])
      expect(described_instance).to receive(:contents_annotations).and_return([{contents_annotations: true}])
    end

    it { is_expected.to eq([{file_name_annotations: true}, {contents_annotations: true}]) }
  end
end
