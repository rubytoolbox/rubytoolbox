# frozen_string_literal: true

require "rubygems"
require "rubygems/remote_fetcher"
require "rubygems/name_tuple"

#
# This sidekiq background job compares the rubygems.org
# gem index against the gems present in the local mirror
# and queues updates on differing gems
#
class RubygemsSyncJob < ApplicationJob
  def perform
    (remote_gems - local_gems).each do |locally_missing_gem|
      RubygemUpdateJob.perform_async locally_missing_gem
    end

    (local_gems - remote_gems).each do |remotely_missing_gem|
      RubygemUpdateJob.perform_async remotely_missing_gem
    end
  end

  def local_gems
    @local_gems ||= Rubygem.pluck(:name)
  end

  # Very similar code is also used in https://github.com/rubytoolbox/catalog/blob/main/spec/catalog_spec.rb#L40-L70
  # it might make sense to extract this into a tiny shared library to avoid
  # drift between the logic
  def remote_gems
    @remote_gems ||= published_gems | prerelease_gems
  end

  def published_gems
    @published_gems ||= ::Gem::Source.new("https://rubygems.org")
                                     .load_specs(:latest)
                                     .map(&:name)
  end

  def prerelease_gems
    @prerelease_gems ||= ::Gem::Source.new("https://rubygems.org")
                                      .load_specs(:prerelease)
                                      .map(&:name)
                                      .uniq
  end
end
