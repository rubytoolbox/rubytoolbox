bundle                                # Install dependencies
bundle exec rspec                     # Run specs
bundle exec foreman start             # Run app processes - rails server, sidekiq, ...
bundle exec rubocop -A                # Run rubocop with autocorrection
AUTOCORRECT=true bundle exec guard    # Run guard, which monitors for file changes and runs specs and rubocop with autocorrection
bin/setup                             # Setup local environment - install dependencies, create database
bin/pull_database                     # Fetch a partial database dump from production and import it locally
rails c                               # Launch rails console
rails dbconsole                       # Launch psql connected to development database
