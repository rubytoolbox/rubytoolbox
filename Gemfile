# frozen_string_literal: true

source "https://rubygems.org"

ruby File.read(File.join(__dir__, ".ruby-version")).strip

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 5.2.0"

# Use postgresql as the database for Active Record
gem "hairtrigger"
gem "pg", "~> 0.18"
gem "pg_search"

gem "kaminari"

# Use Puma as the app server
gem "puma", "~> 3.11"
# Use SCSS for stylesheets
gem "sass-rails", "~> 5.0"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Heroku ruby buildpack installs yarn only when webpacker gem is detected...
gem "webpacker", require: false

gem "font-awesome-rails", "~> 4.7"

gem "addressable"

gem "blueprinter"

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

gem "foreman", require: false

gem "dotenv-rails"

gem "appsignal"

gem "forgery"

gem "rack-canonical-host"
gem "rack-ssl-enforcer"

gem "browser"

gem "github_webhook"

gem "high_voltage"

gem "http"

gem "sidekiq"

gem "redcarpet"
gem "slim-rails"

# Shorter request logs
gem "lograge"
# Needed for logstash json_event formatter for lograge
gem "logstash-event"

# Faster JSON
gem "oj"

# Use CoffeeScript for .coffee assets and views
gem "coffee-rails", "~> 4.2"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "pry-rails"
  gem "rspec-rails"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15", "< 4.0"
  gem "launchy"
  gem "selenium-webdriver"
  # Easy installation and use of selenium webdriver browsers to run system tests
  gem "webdrivers"

  gem "feedjira"

  gem "db-query-matchers"

  gem "retriable"

  gem "timecop"

  gem "rspec-retry"
  gem "rspec_junit_formatter"

  gem "rails-controller-testing"
  gem "simplecov", require: false

  gem "vcr"
  gem "webmock", require: "webmock/rspec"
end

group :development do
  gem "pghero"

  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "web-console", ">= 3.3.0"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"

  gem "guard-bundler", require: false
  gem "guard-rspec", require: false
  gem "guard-rubocop", require: false

  gem "overcommit", require: false

  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
