# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
require "sidekiq/testing"
# Add additional requires below this line. Rails is not loaded until this point!

# It's early stages, and SimpleCov is not happy about those not being loaded
# and hence coverage does not hit 100% - hence, we reference them once so Rails
# auto-loads them. Also, rubocop does not like us referencing things nonsensically...
#
# rubocop:disable Lint/Void
[ApplicationJob, ApplicationMailer, ApplicationRecord]
# rubocop:enable Lint/Void

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
Dir[Rails.root.join("spec", "support", "**", "*.rb")].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

VCR.configure do |c|
  c.ignore_hosts "localhost",
                 "127.0.0.1",
                 # as per https://github.com/titusfortner/webdrivers/wiki/Using-with-VCR-or-WebMock
                 "chromedriver.storage.googleapis.com",
                 "github.com/mozilla/geckodriver/releases",
                 "selenium-release.storage.googleapis.com",
                 "developer.microsoft.com/en-us/microsoft-edge/tools/webdriver"

  c.cassette_library_dir = Rails.root.join("spec", "cassettes")
  c.default_cassette_options = { record: :new_episodes }
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.filter_sensitive_data("<GITHUB_TOKEN>") { ENV["GITHUB_TOKEN"] }
end

Webdrivers.cache_time = 300

# To clean up test output, comment this line to
Capybara.server = :puma, { Silent: true }

Capybara.javascript_driver = :selenium_chrome_headless
Capybara.javascript_driver = :selenium_chrome if ENV["CHROME_DEBUG"].present?

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.before do |example|
    Rails.configuration.http_connect = example.metadata[:real_http]
  end

  config.before type: :feature, js: true do
    # Ensure we are not leaking mobile size from other specs
    Capybara.current_session.current_window.resize_to 1280, 1024
  end

  # Use the viewport: :mobile rspec tag to force the resizing
  # of the chrome window to a "mobile" portrait resolution
  config.before type: :feature, js: true, viewport: :mobile do
    Capybara.current_session.current_window.resize_to 450, 900
  end

  # Some specs assume a clean database, which conflicts with some
  # baseline data provided by fixtures. In this case, this annotation
  # ensures the fixtures get purged before each example.
  config.before clean_database: true do
    DatabaseCleaner.clean_with :truncation
  end

  # Fail js capybara tests when the browser log has JS errors.
  # Snippet courtesy of:
  # https://medium.com/@coorasse/catch-javascript-errors-in-your-system-tests-89c2fe6773b1
  config.after :each, type: :feature, js: true do
    # The latest magic incantation courtesy of https://stackoverflow.com/a/73879550
    errors = page.driver.browser.logs.get(:browser)
    if errors.present?
      aggregate_failures "javascript errrors" do
        errors.each do |error|
          expect(error.level).not_to eq("SEVERE"), error.message
          next unless error.level == "WARNING"

          warn "WARN: javascript warning"
          warn error.message
        end
      end
    end
  end

  #
  # This method allows to submit visual regression testing screenshots
  # to percy.io. To do this
  #
  def take_snapshots!(snapshot_name)
    return unless ENV["PERCY_TOKEN"]

    begin
      # Ensure viewport-size specific capybara specs do not get messed up
      # by percy adjusting the screen size
      @previous_window_size = Capybara.current_session.current_window.size
      page.percy_snapshot snapshot_name.to_s,
                          widths: [400, 1100]
    ensure
      Capybara.current_session.current_window.resize_to(*@previous_window_size)
      @previous_window_size = nil
    end
  end

  # Working around some test flakiness in CI
  # See https://github.com/NoRedInk/rspec-retry
  config.around :each, :js do |ex|
    ex.run_with_retry retry: 3, verbose_retry: true
  end

  config.include FeatureSpecHelpers, type: :feature

  config.around do |example|
    Sidekiq::Testing.inline! if example.metadata[:sidekiq_inline]
    example.run
  ensure
    Sidekiq::Testing.fake!
  end

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end
