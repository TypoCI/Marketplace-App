class Spellcheck::FileName < Spellcheck::Content
  def initialize(content, configuration: nil)
    @content = content
    @configuration = configuration
  end

  def annotations
    invalid_words.collect do |invalid_word|
      {
        path: @content,
        start_line: 1,
        end_line: 1,
        annotation_level: 'warning',
        title: "Filename: #{@content}",
        message: message(invalid_word)
      }
    end.flatten
  end

  def normalized_content
    @normalized_content ||= @content.encode('UTF-8').gsub(/[^a-z \n]/i, ' ')
  end
end
