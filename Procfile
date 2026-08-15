# DEPRECATED for local development: use `mise run server` instead (see
# tasks/server.toml, which mirrors these process definitions). This file
# remains only for the Heroku deployment and will be removed with the
# move to fly.io (#1748).
web:    bundle exec puma --threads 4:$RAILS_MAX_THREADS
worker: bundle exec sidekiq --concurrency $RAILS_MAX_THREADS -q priority -q default
# vite server for development environment
vite: bin/vite dev
# See https://devcenter.heroku.com/articles/release-phase
release: bundle exec rake db:migrate release
