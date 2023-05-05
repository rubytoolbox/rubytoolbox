# frozen_string_literal: true

require "rails_helper"

RSpec.describe RubygemsSyncJob do
  fixtures :all

  let(:job) { described_class.new }

  fake_gem = Struct.new(:name)

  describe "remote spec fetching" do
    def stub_gem_specs_fetch(type:, specs:)
      source = instance_double(Gem::Source)

      allow(Gem::Source).to receive(:new)
        .with("https://rubygems.org")
        .and_return(source)

      allow(source).to receive(:load_specs)
        .with(type).and_return(specs)
    end

    describe "#published_gems" do
      it "acquires the latest rubygems specs and returns all gem names" do
        specs = [fake_gem.new("foo"), fake_gem.new("bar")]
        stub_gem_specs_fetch(type: :latest, specs:)

        expect(job.published_gems).to be == %w[foo bar]
      end
    end

    describe "#prerelease_gems" do
      it "acquires prerelease rubygems specs and returns all unique gem names" do
        specs = [fake_gem.new("foo"), fake_gem.new("bar"), fake_gem.new("bar")]
        stub_gem_specs_fetch(type: :prerelease, specs:)

        expect(job.prerelease_gems).to be == %w[foo bar]
      end
    end

    describe "#remote_gems" do
      it "is the union of the published and prerelease gems" do
        allow(job).to receive(:prerelease_gems).and_return(%w[a b c])
        allow(job).to receive(:published_gems).and_return(%w[a d e f])
        expect(job.remote_gems.sort).to be == %w[a b c d e f]
      end
    end
  end

  describe "#local_gems" do
    it "is a collection of names of local gems" do
      allow(Rubygem).to receive(:pluck).with(:name).and_return(%w[foo bar])
      expect(job.local_gems).to be == %w[foo bar]
    end
  end

  describe "#perform" do
    let(:local_gems)  { %w[rspec what simplecov] }
    let(:remote_gems) { %w[rspec rails simplecov] }

    before do
      allow(job).to receive(:local_gems).and_return(local_gems)
      allow(job).to receive(:remote_gems).and_return(remote_gems)
    end

    it "triggers update jobs for all locally missing gems" do
      allow(RubygemUpdateJob).to receive(:perform_async).with("what")
      expect(RubygemUpdateJob).to receive(:perform_async).with("rails")
      job.perform
    end

    it "triggers update jobs for all remotely missing gems" do
      allow(RubygemUpdateJob).to receive(:perform_async).with("rails")
      expect(RubygemUpdateJob).to receive(:perform_async).with("what")
      job.perform
    end
  end
end
