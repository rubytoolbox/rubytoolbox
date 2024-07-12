# frozen_string_literal: true

source "https://rubygems.org"

ruby File.read(File.join(__dir__, ".ruby-version")).strip

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# NOTE: Remember to bump package.json rails UJS constraint accordingly on upgrades!
gem "rails", "~> 7.1"

# Use postgresql as the database for Active Record
gem "hairtrigger"
gem "pg"
gem "pg_search"
gem "strong_migrations"

gem "aws-sdk-s3"

gem "kaminari"

# Use Puma as the app server
gem "puma"
# Use SCSS for stylesheets
gem "sass-rails"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier"
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Heroku ruby buildpack installs yarn only when webpacker gem is detected...
gem "webpacker", require: false

gem "font-awesome-rails"

gem "addressable"

gem "blueprinter"

gem "dry-struct"
gem "dry-types"

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

gem "foreman", require: false

gem "dotenv-rails"

# https://github.com/appsignal/appsignal-ruby/issues/673
gem "appsignal"

gem "forgery"

gem "rack-canonical-host"

gem "browser"

gem "github_webhook"

gem "high_voltage"

gem "http", "~> 4.4"

gem "sidekiq"

gem "sanitize"
gem "truncato"

gem "redcarpet"
gem "slim-rails"

gem "rouge"

gem "minitar"
gem "terrapin"
gem "zlib"

# Shorter request logs
gem "lograge"
# Needed for logstash json_event formatter for lograge
gem "logstash-event"

# Faster JSON
gem "oj"

gem "image_processing"

# Use CoffeeScript for .coffee assets and views
# gem "coffee-rails", "~> 4.2"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem "rack-cors"

# We use this in development environment / CI for checking the bundle against known vulnerabilities,
# but also at runtime as an easy way to fetch the latest db and sync it into our own database for
# display on the site
gem "bundler-audit"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "pry-rails"
  gem "rspec-rails"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara"
  gem "launchy"
  gem "selenium-webdriver"
  # Easy installation and use of selenium webdriver browsers to run system tests
  gem "webdrivers"

  gem "percy-capybara"

  gem "feedjira"

  gem "db-query-matchers"
  gem "shoulda-matchers"

  gem "database_cleaner-active_record"

  gem "retriable"

  gem "timecop"

  gem "rspec_junit_formatter"
  gem "rspec-retry"

  gem "rails-controller-testing"
  gem "simplecov", require: false

  gem "vcr"
  gem "webmock", require: "webmock/rspec"
end

group :development do
  gem "ruby-lsp"
  gem "ruby-lsp-rails"
  gem "ruby-lsp-rspec"

  gem "brakeman", require: false

  gem "pghero"

  gem "listen"
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "web-console"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen"

  gem "guard-bundler", require: false
  gem "guard-rspec", require: false
  gem "guard-rubocop", require: false

  gem "overcommit", require: false

  gem "rubocop", require: false
  gem "rubocop-capybara", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rspec_rails", require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
