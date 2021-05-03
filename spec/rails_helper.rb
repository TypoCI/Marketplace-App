# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] = 'test'

ENV['ATTR_ENCRYPTED_KEY'] = 'attr_encrypted_key-xxxxxxxxxxxxx'
ENV['ASSET_HOST'] = nil
ENV['GITHUB_APP_SLUG'] = 'typoci-test'
ENV['GITHUB_APP_IDENTIFIER'] = '41496'
ENV['GITHUB_CLIENT_ID'] = 'github_client_id'
ENV['GITHUB_CLIENT_SECRET'] = 'github_client_secret'
ENV['GITHUB_PRIVATE_KEY'] = 'github_private_key'
ENV['GITHUB_MARKETPLACE_SLUG'] = 'typoci-marketplace-test'
ENV['GITHUB_WEBHOOK_SECRET'] = 'github_webhook_secret'
ENV['HEROKU_APP_ID'] = nil
ENV['HEROKU_OAUTH'] = nil
ENV['SLACK_BOT_USER_OAUTH_ACCESS_TOKEN'] = 'slack_bot_user_oauth_access_token'
ENV['URL'] = 'www.example.com'

require 'simplecov'
SimpleCov.start 'rails' do
  # Ignore really small one line files for now.
  add_filter do |source_file|
    source_file.lines.count <= 2
  end
end

require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'webmock/rspec'
# require 'sidekiq/testing'
require 'faker'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

# Disable external connections - Mock them within the app.
WebMock.disable_net_connect!(allow_localhost: true)

OmniAuth.config.test_mode = true

require 'pig_ci'
if RSpec.configuration.files_to_run.count > 1
  PigCI.start do |config|
    # config.generate_html_summary = false
    # config.generate_terminal_summary = false
    config.thresholds.memory = 440
  end
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :rack_test
Capybara.current_driver = :rack_test

Capybara.ignore_hidden_elements = false
