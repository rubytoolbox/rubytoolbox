# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationJob do
  describe ".ephemeral" do
    let(:job) do
      Class.new(described_class) do
        sidekiq_options queue: :priority
        ephemeral
      end
    end

    it "adds the ephemeral options on top of the job's own ones" do
      expect(job.get_sidekiq_options).to include("queue"    => :priority,
                                                 "lock"     => :until_executing,
                                                 "lock_ttl" => 1.day.to_i,
                                                 "retry"    => 3,
                                                 "dead"     => false)
    end
  end
end
