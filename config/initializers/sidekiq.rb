# frozen_string_literal: true

# Job uniqueness via sidekiq-unique-jobs, see ApplicationJob.ephemeral for the
# lock options. The gem does not hook itself into sidekiq: its
# middleware has to be registered on the client side (every process that
# enqueues jobs) and on the server side (the worker process, which also runs
# the periodic reaper for orphaned locks and releases the locks of jobs that
# exhausted their retries).
SidekiqUniqueJobs.configure do |config|
  # Locks live in redis and would persist between examples, while the test
  # suite runs sidekiq in fake or inline mode and asserts on enqueued jobs
  config.enabled = !Rails.env.test?
  config.logger_enabled = !Rails.env.test?
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
end

Sidekiq.configure_server do |config|
  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end

  config.server_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Server
  end

  SidekiqUniqueJobs::Server.configure(config)
end
