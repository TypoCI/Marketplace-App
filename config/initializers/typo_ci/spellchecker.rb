# We run this in after_initialize because the dictionaries memory location
# is forked.
Rails.application.config.after_initialize do
  Spellcheck::Dictionaries.setup!
end
