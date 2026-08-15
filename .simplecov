# frozen_string_literal: true

SimpleCov.configure do
  enable_coverage :branch
  minimum_coverage line: 100, branch: 94.5 unless ENV["SKIP_COVERAGE"]

  skip "/bin/make_fixtures.rb"
end
