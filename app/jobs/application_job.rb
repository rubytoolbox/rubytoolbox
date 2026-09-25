# frozen_string_literal: true

class ApplicationJob
  include Sidekiq::Worker

  # Declares the job's work as ephemeral: the recurring schedule regenerates
  # it anyway, so
  #
  # * enqueuing it while an identical job (same arguments) is still waiting
  #   in the queue is a no-op. The recurring scheduler picks the records that
  #   were updated the longest time ago, which are exactly the ones still
  #   queued whenever the worker falls behind - without the lock the queue
  #   would grow with every scheduler run instead of being bounded by the
  #   number of records. The lock is released once the job starts, so a
  #   follow-up enqueued while it is running is kept (and held again while a
  #   failed job waits for its retry). The ttl caps how long a lock can
  #   outlive its job should it escape both the death handler and the
  #   orphan reaper.
  # * a few quick retries cover transient errors, and a job that still fails
  #   is discarded instead of being kept in the dead set.
  #
  # Jobs without this declaration keep sidekiq's defaults (no lock, the full
  # retry schedule and the dead set), which suits work that nothing enqueues
  # again by itself.
  def self.ephemeral
    sidekiq_options lock:     :until_executing,
                    lock_ttl: 1.day.to_i,
                    retry:    3,
                    dead:     false
  end
end
