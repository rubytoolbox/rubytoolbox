# frozen_string_literal: true

#
# Invoked hourly via sidekiq-scheduler (see config/sidekiq.yml) to trigger
# recurring jobs based on the current time via the Cron service
#
class CronJob < ApplicationJob
  def perform
    Cron.new.run
  end
end
