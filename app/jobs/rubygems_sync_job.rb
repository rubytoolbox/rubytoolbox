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

  def remote_gems
    @remote_gems ||= ::Gem::Source.new("https://rubygems.org")
                                  .load_specs(:latest)
                                  .map(&:name)
  end
end
