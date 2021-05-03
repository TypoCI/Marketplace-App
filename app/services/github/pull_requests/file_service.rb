class Github::PullRequests::FileService
  attr_reader :dictionaries, :configuration

  def initialize(file_hash, repo:, head_sha:, configuration:)
    @file_hash = file_hash
    @repo = repo
    @head_sha = head_sha
    @configuration = configuration || Spellcheck::Configuration.new
  end

  def analysable?
    added_or_modified? && !configuration.excluded_file?(filename)
  end

  def filename
    @file_hash[:filename]
  end

  def file_name_extension
    File.extname(filename).strip.downcase[1..-1]
  end

  def analysable_contents?
    @file_hash[:patch].present?
  end

  def invalid_words
    if analysable_contents?
      (spellcheck_file_name.invalid_words + spellcheck_git_diff.invalid_words).flatten
    else
      spellcheck_file_name.invalid_words
    end
  end

  def file_name_annotations
    @file_name_annotations ||= if configuration.spellcheck_filenames?
                                 spellcheck_file_name.annotations
                               else
                                 []
                               end
  end

  def contents_annotations
    @contents_annotations ||= spellcheck_git_diff.annotations
  end

  def annotations
    if analysable_contents?
      (file_name_annotations + contents_annotations).flatten
    else
      file_name_annotations
    end
  end

  private

  def spellcheck_file_name
    @spellcheck_file_name ||= Spellcheck::FileName.new(filename, configuration: configuration)
  end

  def spellcheck_git_diff
    @spellcheck_git_diff ||= Spellcheck::GitDiff.new(@file_hash[:patch], path: filename, configuration: configuration)
  end

  def added_or_modified?
    @file_hash[:status].in?(%w[added modified])
  end
end
