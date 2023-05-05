# frozen_string_literal: true

require "rails_helper"

RSpec.describe RemoteUpdateSchedulerJob do
  fixtures :all

  let(:job) { described_class.new }
  let(:do_perform) { job.perform }

  def pluckable_relation(attribute, result)
    relation = instance_double ActiveRecord::Relation
    allow(relation).to receive(:pluck).with(attribute).and_return(result)
    relation
  end

  it "purges all github repos without projects from the db" do
    relation = instance_double ActiveRecord::Relation
    allow(GithubRepo).to receive(:without_projects).and_return(relation)
    expect(relation).to receive(:destroy_all)
    do_perform
  end

  it "does not queue gem updates when no gems need an update" do
    allow(Rubygem).to receive(:update_batch).and_return(pluckable_relation(:name, []))
    expect(RubygemUpdateJob).not_to receive(:perform_async)
    do_perform
  end

  it "does not queue repo updates when no repos need an update" do
    allow(GithubRepo).to receive(:update_batch).and_return(pluckable_relation(:path, []))
    expect(GithubRepoUpdateJob).not_to receive(:perform_async)
    do_perform
  end

  # I am not aware of a better way to test consecutive calls here,
  # if you know one, please send a PR :)
  #
  # rubocop:disable RSpec/MultipleExpectations
  it "enqueues updates for all gems returned in the update_batch" do
    allow(Rubygem).to receive(:update_batch).and_return(pluckable_relation(:name, %w[foo bar]))
    expect(RubygemUpdateJob).to receive(:perform_async).with("foo")
    expect(RubygemUpdateJob).to receive(:perform_async).with("bar")
    do_perform
  end

  it "enqueues updates for all github repos returned in the update_batch" do
    allow(GithubRepo).to receive(:update_batch).and_return(pluckable_relation(:path, %w[foo/bar hello/world]))
    expect(GithubRepoUpdateJob).to receive(:perform_async).with("foo/bar")
    expect(GithubRepoUpdateJob).to receive(:perform_async).with("hello/world")
    do_perform
  end
  # rubocop:enable RSpec/MultipleExpectations
end
