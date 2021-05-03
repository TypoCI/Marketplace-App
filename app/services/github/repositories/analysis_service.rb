# Analyse entire repos for their spelling errors.
# Returns a hash of filenames, and their spelling errors.
# Right now only works for open source github repos.
class Github::Repositories::AnalysisService
  def initialize(repository)
    @repository = repository
    @repository_owner = @repository.split('/').first
    @repository_name = @repository.split('/').last
    @repository_url = "git://github.com/#{@repository}.git"
    @repositories_path = Rails.root.join('tmp', 'repos', @repository_owner)
    @repository_path = @repositories_path.join(@repository_name)
  end

  def perform!
    clone_repo!
    analyses_files!
    save_analysis!
    puts "[TypoCI] Analysed #{@repository}"
  end

  private

  def clone_repo!
    FileUtils.mkdir_p(@repositories_path)
    if File.directory?(@repository_path)
      # FileUtils.rm_r(@repository_path)
      # Git.clone(@repository_url, @repository_name, path: @repositories_path, depth: '1')
    else
      Git.clone(@repository_url, @repository_name, path: @repositories_path, depth: '1')
    end
  end

  def save_analysis!
    File.write(@repositories_path.join("#{@repository_name}.txt"), invalid_words.join("\n"))
    File.write(@repositories_path.join("#{@repository_name}.json"), all_annotations.to_json)
  end

  def analyses_files!
    return # Skip threading for now.

    threads = []
    files.in_groups_of((files.size / 2).to_i, false).each_with_index do |group, _index|
      threads << Thread.new { group.collect(&:invalid_words) }
    end
    threads.each(&:join)
  end

  def all_annotations
    @all_annotations ||= files.collect(&:annotations).reject(&:nil?).flatten
  end

  def invalid_words
    @invalid_words ||= files.collect(&:invalid_words).reject(&:nil?).flatten.collect(&:word).uniq.sort
  end

  def configuration
    @configuration ||= Spellcheck::Configuration.new(configuration_options)
  end

  def configuration_options
    if @repository_path.join('.typo-ci.yml').exist?
      YAML.safe_load(@repository_path.join('.typo-ci.yml').read)
    else
      {}
    end
  end

  def repository_files
    @repository_files ||= FileList.new(@repository_path.join('**/*'))
  end

  def files
    @files ||= repository_files.collect do |file|
      Github::Repositories::FileService.new(
        file,
        file.split(@repository_path.to_s).last,
        configuration: configuration
      )
    end.select(&:analysable?).to_a
  end
end
