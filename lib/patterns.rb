# frozen_string_literal: true

module Patterns
  # Ripped from https://github.com/rubygems/rubygems.org/blob/master/lib/patterns.rb and enhanced
  # to also allow slashes as per github
  SPECIAL_CHARACTERS    = ".-_/"
  ALLOWED_CHARACTERS    = "[A-Za-z0-9#{Regexp.escape(SPECIAL_CHARACTERS)}]+"
  ROUTE_PATTERN         = /#{ALLOWED_CHARACTERS}/.freeze
end
