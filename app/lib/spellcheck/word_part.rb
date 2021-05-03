class Spellcheck::WordPart
  attr_reader :word_part

  def initialize(word_part, configuration: nil)
    @word_part = word_part
    @configuration = configuration || Spellcheck::Configuration.new
  end

  def to_s
    return word_part if valid?

    suggestions.first || '¯\_(ツ)_/¯'
  end

  def valid?
    @valid ||= word_part.length <= 2 ||
               word_part == word_part.upcase ||
               @configuration.excluded_word?(word_part) ||
               word_part_in_any_of_the_dictionaries? ||
               (suggestions&.first || '').split(/[- ]/).join.downcase == word_part.downcase ||
               suggestions.first&.upcase == word_part.upcase
  end

  # Get the suggestions from the dictionaries, then merge then
  # in an interlaced fashion.
  def suggestions
    @suggestions ||= begin
      dictionary_suggestions = dictionaries
                               .collect { |dictionary| suggestions_for_word_part_for_dictionary(dictionary) }
                               .reject(&:empty?)
                               .inject { |final_array, array| final_array.zip(array) }
      dictionary_suggestions = (dictionary_suggestions || []).flatten.compact.uniq[0, 4]

      dictionary_suggestions.collect!(&:capitalize) if capitalized?
      dictionary_suggestions
    end
  end

  private

  def dictionaries
    @configuration.dictionaries
  end

  def suggestions_for_word_part_for_dictionary(dictionary)
    dictionary.suggest(word_part.downcase)[0, 2]
  rescue Encoding::UndefinedConversionError
    []
  end

  def word_part_in_any_of_the_dictionaries?
    dictionaries.any? do |dictionary|
      check_word_part_in_dictionary?(dictionary)
    end
  end

  def check_word_part_in_dictionary?(dictionary)
    return true if dictionary.check?(word_part.encode(dictionary.encoding))
    return false if word_part == word_part.delete_suffix('able')

    dictionary.check?(word_part.delete_suffix('able').encode(dictionary.encoding))
  rescue Encoding::UndefinedConversionError
    false
  end

  def capitalized?
    word_part == word_part.capitalize
  end
end
