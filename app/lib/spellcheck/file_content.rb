class Spellcheck::FileContent < Spellcheck::Content
  def initialize(content, path:, configuration: nil)
    @content = content
    @path = path
    @configuration = configuration
  end

  def annotations
    content_lines.collect.with_index do |file_line, index|
      invalid_words.collect do |invalid_word|
        start_column = file_line.index(/\b#{invalid_word.word}\b/)
        next if start_column.nil?

        start_column += 1

        {
          path: @path,
          start_line: index + 1, # File contents start at 1
          end_line: index + 1, # File contents start at 1
          start_column: start_column,
          end_column: start_column + invalid_word.word.length,
          annotation_level: 'warning',
          title: invalid_word.word,
          message: message(invalid_word)
        }
      end.reject(&:nil?)
    end.reject(&:nil?).flatten
  end
end
