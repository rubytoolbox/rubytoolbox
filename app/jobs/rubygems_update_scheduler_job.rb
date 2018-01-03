# frozen_string_literal: true

#
# This sidekiq background job enqueues gem data updates.
# It tries to distribute updates evenly throughout the day
# to avoid creating a thundering herd at midnight.
#
class RubygemsUpdateSchedulerJob < ApplicationJob
  def perform
    Rubygem.update_batch.each do |name|
      RubygemUpdateJob.perform_async name
    end
  end
end
