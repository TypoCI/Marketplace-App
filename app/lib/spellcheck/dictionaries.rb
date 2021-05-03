# This opens the Hunspell dictionaries, and stores references in memory.
# This means we won't repopulate the DB with new words each request.
class Spellcheck::Dictionaries
  def self.setup!
    FFI::Hunspell.directories = [
      Rails.root.join('db/dict/imported'),
      Rails.root.join('db/dict/combined_contextual'),
      Rails.root.join('node_modules')
    ]
  end

  def self.imported
    @imported ||= {
      'de' => FFI::Hunspell.dict('dictionary-de/index'),
      'en' => FFI::Hunspell.dict('en_US-large'),
      'en_GB' => FFI::Hunspell.dict('en_GB'),
      'es' => FFI::Hunspell.dict('dictionary-es/index'),
      'fr' => FFI::Hunspell.dict('dictionary-fr/index'),
      'it' => FFI::Hunspell.dict('dictionary-it/index'),
      'nl' => FFI::Hunspell.dict('dictionary-nl/index'),
      'pt' => FFI::Hunspell.dict('dictionary-pt/index'),
      'pt_BR' => FFI::Hunspell.dict('pt_BR'),
      'tr' => FFI::Hunspell.dict('dictionary-tr/index'),
      'combined' => FFI::Hunspell.dict('combined')
    }
  end
end
