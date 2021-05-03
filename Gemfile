source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
ruby File.read(".ruby-version").chomp

gem "attr_encrypted"
gem "barnes"
gem "bootsnap", ">= 1.4.2", require: false
gem "devise"
gem "dotenv-rails"
gem "ffi-hunspell"
gem "git"
gem "git_diff_parser"
gem "github_webhook", "~> 1.1"
gem "json-schema"
gem "jwt"
gem "lograge"
gem "meta-tags"
gem "mimemagic"
gem "octokit"
gem "omniauth", "~> 1.9.1"
gem "omniauth-github"
gem "pg", ">= 0.18", "< 2.0"
gem "platform-api"
gem "premailer-rails"
gem "puma", "~> 5.1"
gem "rails", "~> 6.1.0", ">= 6.0.3.2"
gem "redis", "~> 4.0"
gem "rendezvous"
gem "sass-rails", ">= 6"
gem "sentry-raven"
gem "sidekiq"
gem "sidekiq-cron", github: "MikeRogers0/sidekiq-cron", branch: "bug/fix-redis-warning"
gem "slack-ruby-bot"
gem "turbolinks", "~> 5"
gem "webpacker", "~> 5.0"

group :development, :test do
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "factory_bot_rails"
  gem "rspec-rails", "~> 4.0"
end

group :development do
  gem "i18n-debug"
  gem "letter_opener"
  gem "letter_opener_web", "~> 1.0"
  gem "listen", ">= 3.0.5", "< 3.5"
  gem "standard"
end

group :test do
  gem "capybara", ">= 2.15"
  gem "faker"
  gem "pig-ci-rails"
  gem "selenium-webdriver"
  gem "simplecov", require: false
  gem "webdrivers"
  gem "webmock"
end
