# frozen_string_literal: true

require "sidekiq_unique_jobs/testing"

# See ApplicationJob.ephemeral for the reasoning behind these two
RSpec.shared_examples "an ephemeral job" do
  let(:job_options) { described_class.get_sidekiq_options }

  it "is locked while waiting in the queue" do
    expect(job_options).to include("lock" => :until_executing, "lock_ttl" => 1.day.to_i)
  end

  it "is discarded after a few retries" do
    expect(job_options).to include("retry" => 3, "dead" => false)
  end

  it "has valid sidekiq-unique-jobs options" do
    expect(described_class).to have_valid_sidekiq_options
  end
end

RSpec.shared_examples "a durable job" do
  let(:job_options) { described_class.get_sidekiq_options }

  it "keeps sidekiq's default retry schedule and dead set without a lock" do
    expect(job_options).to include("retry" => true).and exclude("lock", "dead")
  end
end
