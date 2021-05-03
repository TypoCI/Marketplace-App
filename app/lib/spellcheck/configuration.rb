require 'json-schema'

class Spellcheck::Configuration
  attr_reader :custom_configuration
  attr_writer :excluded_words
  attr_accessor :known_words

  DEFAULT_VALUES = {
    dictionaries: %w[en en_GB],
    excluded_files: [
      'vendor/**/*',
      'node_modules/**/*',
      '*.key',
      '*.enc',
      '*.min.css',
      '*.css.map',
      '*.min.js',
      '*.js.map',
      'package-lock.json',
      'yarn.lock',
      'Gemfile.lock',
      '.typo-ci.yml',
      '.github/.typo-ci.yml',
      '*.aff',
      '*.dic',
      '*.mk'
    ],
    excluded_words: ['typoci'],
    spellcheck_filenames: true
  }.freeze

  SCHEMA = {
    type: 'object',
    required: [],
    properties: {
      dictionaries: {
        type: 'array',
        items: {
          type: 'string',
          enum: %w[
            de
            en
            en_GB
            es
            fr
            it
            nl
            pt
            pt_BR
            tr
          ]
        }
      },
      excluded_words: {
        type: 'array',
        items: {
          type: 'string'
        }
      },
      excluded_files: {
        type: 'array',
        items: {
          type: 'string'
        }
      },
      spellcheck_filenames: {
        type: 'boolean'
      }
    }
  }.freeze

  def initialize(custom_configuration = {})
    @known_words = {}
    @custom_configuration = if custom_configuration.is_a?(Hash)
                              custom_configuration.symbolize_keys.slice(*DEFAULT_VALUES.keys)
                            else
                              {}
                            end
  end

  def dictionaries
    @dictionaries ||= (to_h[:dictionaries] + ['combined']).collect do |dictionary|
      Spellcheck::Dictionaries.imported[dictionary]
    end
  end

  def spellcheck_filenames?
    to_h[:spellcheck_filenames]
  end

  def excluded_files
    to_h[:excluded_files]
  end

  def excluded_words
    to_h[:excluded_words]
  end

  def excluded_words=(value)
    to_h[:excluded_words] = value
  end

  def excluded_word?(word)
    excluded_words.any? { |excluded_word| excluded_word.casecmp?(word) }
  end

  def excluded_file?(filename)
    # Taken from rubocop
    excluded_files.any? do |pattern|
      if filename.start_with?('.')
        File.fnmatch?(pattern, filename, File::FNM_EXTGLOB | File::FNM_DOTMATCH)
      else
        File.fnmatch?(pattern, filename, File::FNM_EXTGLOB)
      end
    end
  end

  def to_h
    @to_h ||= if custom_configuration_valid?
                DEFAULT_VALUES.merge(custom_configuration)
              else
                DEFAULT_VALUES.dup
              end
  end

  private

  def custom_configuration_valid?
    JSON::Validator.validate(SCHEMA, custom_configuration)
  end
end
