class Spellcheck::GitDiff < Spellcheck::Content
  def initialize(diff, path:, configuration: nil)
    @diff = diff
    @path = path
    @configuration = configuration

    @patch = GitDiffParser::Patch.new(@diff)
    @content = @patch.changed_lines.collect(&:content).join("")
  end

  def annotations
    @patch.changed_lines.collect do |patch_line|
      invalid_words.collect do |invalid_word|
        start_column = patch_line.content.index(/\b#{invalid_word.word}\b/)
        next if start_column.nil?

        {
          path: @path,
          start_line: patch_line.number,
          end_line: patch_line.number,
          start_column: start_column,
          end_column: start_column + invalid_word.word.length,
          annotation_level: "warning",
          title: invalid_word.word,
          message: message(invalid_word)
        }
      end.reject(&:nil?)
    end.reject(&:nil?).flatten
  end
end
