# frozen_string_literal: true

require "rails_helper"

RSpec.describe Cron, type: :service do
  let(:cron) { described_class.new }

  def time_at(hour)
    Time.utc(2018, 1, 3, hour, 10, 12)
  end

  it "enqueues RubygemsSyncJob at 0 am" do
    expect(RubygemsSyncJob).to receive(:perform_async)
    cron.run time: time_at(0)
  end

  it "does not enqueue RubygemsSyncJob at 1 am" do
    expect(RubygemsSyncJob).not_to receive(:perform_async)
    cron.run time: time_at(1)
  end
end
