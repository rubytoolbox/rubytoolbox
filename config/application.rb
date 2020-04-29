# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Rubytoolbox
  class Application < Rails::Application
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.lograge.enabled = true
    config.lograge.formatter = Lograge::Formatters::Logstash.new

    config.active_record.schema_format = :sql

    config.assets.paths << Rails.root.join("node_modules")

    config.generators do |c|
      # Don't generate system test files.
      c.system_tests = nil

      c.helper       = false
      c.javascripts  = false
      c.stylesheets  = false
    end

    config.http_connect = true
  end
end
