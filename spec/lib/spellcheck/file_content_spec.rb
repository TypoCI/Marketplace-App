require "rails_helper"

RSpec.describe Spellcheck::FileContent do
  let(:path) { "spec/fixtures/files/ruby_sample.rb" }

  describe "#annotations" do
    subject { described_class.new(contents, path: path, configuration: Spellcheck::Configuration.new).annotations }

    context "Ruby with spelling errors file" do
      let(:contents) { Rails.root.join("spec", "fixtures", "files", "misspelt_files", "ruby_sample.rb").read }

      it { expect(subject.count).to eq(4) }
    end

    context "Markdown with one spelling errors in file" do
      let(:contents) { Rails.root.join("spec", "fixtures", "files", "misspelt_files", "README.md").read }

      it { expect(subject.count).to eq(1) }
    end

    context "files without spelling errors" do
      Rails.root.join("app").glob("*/**")
        .reject { |pathname| File.directory?(pathname) }
        .each do |pathname|
        context pathname.to_s do
          let(:contents) { pathname.read }
          let(:path) { pathname.to_s }

          it { is_expected.to eq([]) }
        end
      end
    end
  end

  describe "#invalid_words" do
    subject { described_class.new(contents, path: path, configuration: configuration).invalid_words }

    let(:configuration) { Spellcheck::Configuration.new }

    context "Brazilian Dictionary" do
      let(:configuration) { Spellcheck::Configuration.new(dictionaries: %w[en pt pt_BR]) }
      let(:contents) do
        "aprender código Código Educodar educodar concorda conduta inscrever quero tricerácio voluntárias técnica"
      end

      it { expect(subject.collect(&:word)).to eq([]) }
    end
  end

  describe "#normalized_content" do
    subject { described_class.new(contents, path: path).normalized_content }

    context "contents contains a url" do
      let(:contents) { "link https://google.com/ endlink" }

      it { is_expected.to eq("link                     endlink") }
    end

    context "contents contains a md5 hash" do
      let(:contents) { "hash 0800fc577294c34e0b28ad2839435945 end" }

      it { is_expected.to eq("hash                                  end") }
    end

    context "contents contains special characters" do
      let(:contents) { "special $apple$pies end" }

      it { is_expected.to eq("special  apple pies end") }
    end

    context "contents contains a sha512 hash" do
      let(:contents) do
        "integrity sha512-E6uQ4kRrTX9URN9s/lIbqTAztwEP+vzVrcmHE8EQ9YnuT9J8Es5Wrd8n9BKg1a0oZ5EgEke/EQFgUsp18dSTBw=="
      end

      it {
        expect(subject).to eq("integrity                                                                                                ")
      }
    end

    context "contents contains a sha384 hash" do
      let(:contents) do
        "integrity sha384-FMDsKPnkIpujeBBbBOK2v3MU7o6cGBg/dMoKxVVm9hqzhcPd19Tq6/PeM6FKw3ZI"
      end

      it {
        expect(subject).to eq("integrity                                                                        ")
      }
    end

    context "contents contains a sha1 hash" do
      let(:contents) { "integrity sha1-x57Zf380y48ro+yXkLzDZkdLS3k=" }

      it { is_expected.to eq("integrity                                  ") }
    end

    context "contents is the simple analytics script" do
      let(:contents) do
        '<script async defer src="https://scripts.simpleanalyticscdn.com/sri/v7.js" integrity="sha256-h3cSuH9qvT4n4b2GyoWiT2JneSepI35f+ZJuh8PpzQ8= sha384-FMDsKPnkIpujeBBbBOK2v3MU7o6cGBg/dMoKxVVm9hqzhcPd19Tq6/PeM6FKw3ZI sha512-Jz0QmBIkE5jm7CHPxYqmZCv88BziX3GwL8qVYPUSMgZxTYMyi8nQcEetTkw/dt/7VdJzFRSLLWmDwRFSdBILBA==" crossorigin="anonymous"></script>'
      end

      it {
        expect(subject).to eq(" script async defer src                                                    integrity  sha                                                                                                                                                                                                                          crossorigin  anonymous    script ")
      }
    end

    context "contents contains hexcode" do
      let(:contents) { "color: #fff; color: #1e1e1e;" }

      it { is_expected.to eq("color        color          ") }
    end

    context "contents contains hexcode" do
      let(:contents) { "border-bottom: 3px solid lighten(#ddd, 10);" }

      it { is_expected.to eq("border-bottom   px solid lighten           ") }
    end

    context "contents contains hexcode" do
      let(:contents) { "#333'" }

      it { is_expected.to eq("     ") }
    end

    context "contents contains hexcode" do
      let(:contents) { "$body-bg: #fff !default;" }

      it { is_expected.to eq(" body-bg        default ") }
    end

    context "contents contains hexcode" do
      let(:contents) { "$shiny-edge-color: rgba(#fff, .5) !default;" }

      it { is_expected.to eq(" shiny-edge-color  rgba            default ") }
    end

    context "contents contains windows hash thingy" do
      let(:contents) { "<Project>{79ebcf73-afc0-45f4-b3a0-91adf1eb0edc}</Project>" }

      it { is_expected.to eq(" Project                                         Project ") }
    end

    context "contents contains shouldn't" do
      let(:contents) { "'so that shouldn't do '" }

      it { is_expected.to eq(" so that shouldn't do  ") }
    end

    context "contents contains shouldn't" do
      let(:contents) do
        "         * 4. After we’ve iterated through every symbol of every module, any symbol left in Bucket C means that step 3 didn’t"
      end

      it {
        expect(subject).to eq("              After we’ve iterated through every symbol of every module  any symbol left in Bucket C means that step   didn’t")
      }
    end

    context "contents contains a variable" do
      let(:contents) { "var something = 'hello world';" }

      it { is_expected.to eq("var something    hello world  ") }
    end

    context "contents is a really long line length" do
      let(:contents) { ['var apple="pickle";' * 27, "\n", "some_line"].join }

      it { is_expected.to eq(["                   " * 27, "\n", "some line"].join) }
    end

    context "contents is json node ID" do
      let(:contents) { '"node_id": "MDEwOlJlcG9zaXRvcnkyMTAxNDc0Mzk=",' }

      it { is_expected.to eq(" node id                                      ") }
    end

    context "contents is a SHA" do
      let(:contents) { '"sha": "f80afca0b052aef2d832fc87343ad7a23bd20443",' }

      it { is_expected.to eq(" sha                                              ") }
    end

    context "contents is a regex expression" do
      let(:contents) { "/^[a-z0-9_-]{3,16}$/" }

      it { is_expected.to eq("   a-z              ") }
    end

    context "contents is a regex expression from php" do
      let(:contents) { "preg_match('/<td[^>]*>(.*?)<\/td>/im', $html, $matches);" }

      it { is_expected.to eq("preg match    td             td        html   matches  ") }
    end

    context "contents is a regex expression from php with hashes" do
      let(:contents) { "preg_match('#(<\s*head[^>]*>\s*.*)<\s*body[^>]*>#ism', $html, $match);" }

      it { is_expected.to eq("preg match       head              body              html   match  ") }
    end

    context "contents is a hashtag" do
      let(:contents) { "#apple" }

      it { is_expected.to eq(" apple") }
    end

    context "contents is a xml with colour hash in it" do
      let(:contents) { "<TileColor>#ffffff</TileColor>" }

      it { is_expected.to eq(" TileColor          TileColor ") }
    end

    context "contents is JSON with colour hash in it" do
      let(:contents) { '"backgroundColor": "#ffffff"' }

      it { is_expected.to eq(" backgroundColor            ") }
    end

    context "contents is a middleman include helper with underscore" do
      let(:contents) { "{% include _head.html %}" }

      it { is_expected.to eq("   include  head html   ") }
    end

    context "contents is ruby command with hyphens starting the words" do
      let(:contents) { "ruby -Ilib -w -W2 lib/rubocop.rb 2>&1" }

      it { is_expected.to eq("ruby  Ilib  w  W  lib rubocop rb     ") }
    end

    context "contents has letter with accents" do
      let(:contents) { "café fiancée naïve" }

      it { is_expected.to eq("café fiancée naïve") }
    end

    context "contents is not UTF-8 encoding" do
      let(:contents) do
        "V by Example é uma introdução direta ao V usando exemplos de programas anotados.".encode("ISO-8859-1")
      end

      it { is_expected.to eq("V by Example é uma introdução direta ao V usando exemplos de programas anotados ") }
    end

    context "contents is not a latin alphabet" do
      let(:contents) { "是否显示stdin的日志" }

      it { is_expected.to eq("    stdin   ") }
    end

    context "contents is words starting with quote and hyphen" do
      let(:contents) { " -apple pear-pear 'apple \"apple" }

      it { is_expected.to eq("  apple pear-pear  apple  apple") }
    end

    context "contents is google analytics code sample" do
      let(:contents) { "window,document,'script','dataLayer','GTM-MQJ6XZ5'" }

      it { is_expected.to eq("window document  script   dataLayer   GTM-MQJ XZ  ") }
    end

    context "contents is a start of a ruby array" do
      let(:contents) { "['-newkey'] [\"-newkey" }

      it { is_expected.to eq("   newkey      newkey") }
    end

    context "contents is a python line with f' at start" do
      let(:contents) { "                f'ModelCheckpoint mode {mode} is unknown, '" }

      it { is_expected.to eq("                  ModelCheckpoint mode  mode  is unknown   ") }
    end

    context "contents is a comment in python" do
      let(:contents) { "'''Get number of parameters in each layer'''" }

      it { is_expected.to eq("   Get number of parameters in each layer   ") }
    end

    context "contents is a mixin in SCSS" do
      let(:contents) { "@mixin btn-outline($bg, $color: #ffffff) {" }

      it { is_expected.to eq(" mixin btn-outline  bg   color            ") }
    end
  end
end
