class Github::Repositories::FileService
  attr_reader :configuration, :repo_file_path

  def initialize(file, repo_file_path, configuration:)
    @file = file
    @repo_file_path = repo_file_path
    @configuration = configuration || Spellcheck::Configuration.new
  end

  def analysable?
    @analysable ||= File.file?(@file) && !configuration.excluded_file?(@repo_file_path) && file_is_maybe_text? && !@repo_file_path.include?("~")
  end

  def invalid_words
    (spellcheck_file_name.invalid_words + spellcheck_file_content.invalid_words).flatten
  end

  def file_name_annotations
    @file_name_annotations ||= spellcheck_file_name.annotations
  end

  def contents_annotations
    @contents_annotations ||= spellcheck_file_content.annotations
  end

  def annotations
    (file_name_annotations + contents_annotations).flatten
  end

  private

  # Look at the extension, if it's something that looks like a text format
  # that's great.
  # Annoyingly MimeMagic returns nil if it can't find a match instead of a null object.
  def file_is_maybe_text?
    mime_magic_lookup = MimeMagic.by_path(@file)
    return file_contents.valid_encoding? if mime_magic_lookup.nil?

    mime_magic_lookup.text? && !mime_magic_lookup.image?
  end

  def file_contents
    puts "Opening file: #{@file}"
    File.read(@file)
  end

  def spellcheck_file_name
    @spellcheck_file_name ||= Spellcheck::FileName.new(repo_file_path, configuration: configuration)
  end

  def spellcheck_file_content
    @spellcheck_file_content ||= Spellcheck::FileContent.new(file_contents, path: repo_file_path,
                                                                            configuration: configuration)
  end
end
