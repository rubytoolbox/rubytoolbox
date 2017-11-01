# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

use Rack::SslEnforcer if Rails.env.production?
use Rack::CanonicalHost, ENV["CANONICAL_HOST"] if ENV["CANONICAL_HOST"].present?
run Rails.application
