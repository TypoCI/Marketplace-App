release: bash bin/release-tasks.sh
web: bundle exec rails s -p $PORT
worker: bundle exec sidekiq -C config/sidekiq.yml
