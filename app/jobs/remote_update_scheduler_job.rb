# frozen_string_literal: true

#
# This sidekiq background job enqueues gem and github repo
# data updates.
#
# It tries to distribute updates evenly throughout the day
# to avoid creating a thundering herd at midnight.
#
class RemoteUpdateSchedulerJob < ApplicationJob
  def perform
    Rubygem.update_batch.each do |name|
      RubygemUpdateJob.perform_async name
    end

    GithubRepo.update_batch.each do |path|
      GithubRepoUpdateJob.perform_async path
    end
  end
end
