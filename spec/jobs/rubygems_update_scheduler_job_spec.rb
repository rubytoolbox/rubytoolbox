# frozen_string_literal: true

require "rails_helper"

RSpec.describe RubygemsUpdateSchedulerJob, type: :job do
  let(:job) { described_class.new }
  let(:do_perform) { job.perform }

  it "does nothing when no gems need an update" do
    allow(Rubygem).to receive(:update_batch).and_return([])
    expect(RubygemUpdateJob).not_to receive(:perform_async)
    do_perform
  end

  # I am not aware of a better way to test consecutive calls here,
  # if you know one, please send a PR :)
  #
  # rubocop:disable RSpec/MultipleExpectations
  it "enqueues all gems returned in the update_batch" do
    allow(Rubygem).to receive(:update_batch).and_return(%w[foo bar])
    expect(RubygemUpdateJob).to receive(:perform_async).with("foo")
    expect(RubygemUpdateJob).to receive(:perform_async).with("bar")
    do_perform
  end
  # rubocop:enable RSpec/MultipleExpectations
end
