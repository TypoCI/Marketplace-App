class Spellcheck::Content
  attr_reader :configuration

  def initialize(_contents, configuration: nil)
    raise NotImplementedError
  end

  def annotations
    raise NotImplementedError
  end

  def normalized_content
    @normalized_content ||= begin
                              @content
                                .encode('UTF-8')
                                .gsub(%r{([^\n]){500,}}) { |phrase| ' ' * phrase.length } # Long line lengths
                                .gsub(%r{\#([a-f0-9]{2,6})[\,\; \!\<\"\'\)]}i) { |phrase| ' ' * phrase.length } # colour hashes
                                .gsub(%r{sha512\-([a-z0-9\+/]{60,})==}i) { |phrase| ' ' * phrase.length } # Remove any sha512 looking things
                                .gsub(%r{sha384\-([a-z0-9\+\//]{60,})}i) { |phrase| ' ' * phrase.length } # Remove any sha512 looking things
                                .gsub(%r{ ([a-z0-9\_\-]{50,})==}i) { |phrase| ' ' * phrase.length } # Remove any x-amz-cf-id looking things
                                .gsub(%r{sha1\-([a-z0-9\+/]{20,})=}i) { |phrase| ' ' * phrase.length } # Remove any sha1 looking things
                                .gsub(%r{([a-z0-9\+/]{18,})=}i) { |phrase| ' ' * phrase.length } # Remove any node ids
                                .gsub(%r{\{([a-z0-9\-]{36,})\}}i) { |phrase| ' ' * phrase.length } # Remove any windows hashes looking things
                                .gsub(/([a-z0-9\+]{32,})/i) { |phrase| ' ' * phrase.length } # Remove any md5 looking things
                                .gsub(/([a-z0-9]{20,})/) { |phrase| ' ' * phrase.length } # Webpacker hashes
                                .gsub(/(\: )/i) { |phrase| ' ' * phrase.length } # Semicolons in CSS rules
                                .gsub(%r{[\#\/]([gmiXxsuUAJD]{2,11})[\,\;\)\'\"\ \/]}i) { |phrase| ' ' * phrase.length } # regex endings
                                .gsub(URI::DEFAULT_PARSER.make_regexp) { |phrase| ' ' * phrase.length } # urls
                                .gsub(/[^[\p{Latin}]\'\’\-\n]/i, ' ') # Remove any special characters
                                .gsub(/'''/i, '   ') # Python Quotes
                                .gsub(/ [\'\’\-]/i, '  ') # Words starting with hyphens funny quotes
                                .gsub(/ [\'\’\-]/i, '  ') # Words starting with hyphens funny quotes (Second time)
                                .gsub(/ f'/i, '   ') # Lines starting with f'Message
                                .gsub(/^[\'\’]|[\'\’]$|[\'\’]\ |\ [\'\’]/i) { |phrase| ' ' * phrase.length } # Remove stand-alone quotes
                            rescue ArgumentError
                              ''
                            end
  end

  def invalid_words
    @invalid_words ||= all_content_words.collect do |word|
      configuration.known_words[word] ||= Spellcheck::Word.new(word, configuration: configuration)
    end.reject(&:valid?)
  end

  private

  def all_content_words
    @all_content_words ||= content_lines.collect do |content_line|
      content_line.split(' ')
    end.flatten.uniq.sort
  end

  def content_lines
    @content_lines ||= normalized_content.split("\n")
  end

  def message(invalid_word)
    I18n.t("excluded_words.#{invalid_word.word.downcase}", word: invalid_word.word, suggestion: invalid_word.suggestion, scope: ['lib', self.class.name.underscore], default: nil) ||
      I18n.t('message', word: invalid_word.word, suggestion: invalid_word.suggestion, scope: ['lib', self.class.name.underscore])
  end
end
