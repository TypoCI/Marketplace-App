class Spellcheck::Word
  attr_reader :word, :configuration

  def initialize(word, configuration: nil)
    @word = word
    @configuration = configuration
  end

  def valid?
    @valid ||= word.length <= 2 ||
               word == word.upcase ||
               single_word.valid? ||
               word_parts.all?(&:valid?) ||
               suggestion.split(/[- ]/).join.downcase == word.downcase
  end

  def suggestion
    @suggestion ||= word_parts.inject(word) do |final_word, word_part|
      final_word.sub(word_part.word_part, word_part.to_s)
    end&.encode('UTF-8')
  end

  private

  def single_word
    Spellcheck::WordPart.new(word, configuration: configuration)
  end

  def word_parts
    @word_parts ||= word_parts_array.collect do |word_part|
      Spellcheck::WordPart.new(word_part, configuration: configuration)
    end
  end

  def word_parts_array
    @word_parts_array ||= word.tr('-', '_').gsub(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2').gsub(/([a-z\d])([A-Z])/,
                                                                                         '\1_\2').split('_').select(&:present?)
  end
end
