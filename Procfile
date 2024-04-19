web:    bundle exec puma --threads 4:$RAILS_MAX_THREADS
worker: bundle exec sidekiq --concurrency $RAILS_MAX_THREADS -q priority -q default
# See https://devcenter.heroku.com/articles/release-phase
release: bundle exec rake db:migrate release
