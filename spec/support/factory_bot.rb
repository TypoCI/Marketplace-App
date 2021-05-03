RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

# https://relishapp.com/rspec/rspec-rails/v/3-8/docs/file-fixture
# https://blog.eq8.eu/til/factory-bot-trait-for-active-storange-has_attached.html
FactoryBot::SyntaxRunner.class_eval do
  include ActionDispatch::TestProcess

  def self.fixture_path
    RSpec.configuration.fixture_path
  end
end
