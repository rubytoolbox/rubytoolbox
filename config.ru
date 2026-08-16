# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

# The health check endpoint is exempt from canonical host redirects since the
# hosting platform probes it with non-canonical Host headers - redirecting those
# requests would make the machines appear unhealthy
use Rack::CanonicalHost, ENV["CANONICAL_HOST"], ignore: ->(uri) { uri.path == "/up" } if ENV["CANONICAL_HOST"].present?

run Rails.application
