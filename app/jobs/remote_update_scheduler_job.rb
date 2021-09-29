# frozen_string_literal: true

#
# This sidekiq background job enqueues gem and github repo
# data updates and purges orphaned github repo records.
#
# It tries to distribute updates evenly throughout the day
# to avoid creating a thundering herd at midnight.
#
class RemoteUpdateSchedulerJob < ApplicationJob
  def perform
    # If a repo reference changes from a gem, we leave the repo
    # behind in the db. This purges it afterwards since we don't need it
    # anymore
    GithubRepo.without_projects.destroy_all

    Rubygem.update_batch.pluck(:name).each do |name|
      RubygemUpdateJob.perform_async name
    end

    GithubRepo.update_batch.pluck(:path).each do |path|
      GithubRepoUpdateJob.perform_async path
    end
  end
end
