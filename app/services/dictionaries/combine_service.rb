# This combines all the context (programming languages and other terms) into a
# single file. Which should improve performance.
class Dictionaries::CombineService
  def initialize
    @input_directory = Rails.root.join('db', 'dict', 'contextual')
    @cspell_input_directory = Rails.root.join('node_modules', '@cspell')
    @output_directory = Rails.root.join('db', 'dict', 'combined_contextual')
    @words = []
  end

  def run!
    build_word_list
    add_words_from_cspell
    write_word_list
  end

  private

  def build_word_list
    @words = @input_directory.glob('*.dic').collect do |dictionary_file|
      dictionary_file.readlines.drop(1).collect(&:strip)
    end.flatten.uniq.sort.select(&:present?)
  end

  def add_words_from_cspell
    %w[typescript html-symbol-entities fonts software-terms scala rust ruby python powershell php npm node fullstack
       elixir django dotnet companies bash aws].each do |language|
      @words += @cspell_input_directory.join("dict-#{language}").glob('*.txt.gz').collect do |file|
        Zlib::GzipReader.open(file).readlines.collect(&:strip)
      end.flatten
    end

    @words.flatten.uniq.sort
  end

  def write_word_list
    @output_directory.join('combined.dic').open('w') do |f|
      f << "#{@words.size}\n"
      f << @words.join("\n")
    end
  end
end
