# frozen_string_literal: true

require "rails_helper"

RSpec.describe RubygemUpdateJob do
  fixtures :all

  let(:job) { described_class.new }
  let(:do_perform) { job.perform gem_name }
  let(:gem_name) { "rspec" }

  describe "#perform" do
    let(:expected_attributes) do
      {
        authors:                    "Steven Baker, David Chelimsky, Myron Marston",
        bug_tracker_url:            nil,
        current_version:            "3.7.0",
        documentation_url:          "http://relishapp.com/rspec",
        downloads:                  145_999_055,
        homepage_url:               "http://github.com/rspec",
        licenses:                   %w[MIT],
        mailing_list_url:           "http://rubyforge.org/mailman/listinfo/rspec-users",
        name:                       "rspec",
        source_code_url:            "http://github.com/rspec/rspec",
        wiki_url:                   nil,
        first_release_on:           Date.new(2005, 8, 11),
        latest_release_on:          Date.new(2017, 10, 17),
        releases_count:             3,
        reverse_dependencies_count: 6,
      }
    end

    it "applies the remote info attributes" do
      do_perform

      expect(Rubygem.find(gem_name)).to have_attributes(expected_attributes)
    end

    it "changes the updated_at timestamp regardless of changes" do
      described_class.new.perform gem_name
      Rubygem.find(gem_name).update! updated_at: 2.days.ago
      expect { do_perform }.to(change { Rubygem.find(gem_name).updated_at })
    end

    it do
      expect(ProjectUpdateJob).to receive(:perform_async).with(gem_name)
      do_perform
    end

    it do
      expect(RubygemCodeStatsJob).to receive(:perform_async).with(gem_name)
      do_perform
    end

    context "when current_version didn't change during update" do
      before do
        Factories.rubygem("rspec").tap { it.update! current_version: expected_attributes.fetch(:current_version) }
      end

      it do
        expect(RubygemCodeStatsJob).not_to receive(:perform_async)
        do_perform
      end
    end

    it "stores quarterly release counts" do
      do_perform
      expected = { "2005-3" => 1, "2017-2" => 1, "2017-4" => 1 }
      expect(Rubygem.find(gem_name).quarterly_release_counts).to eq expected
    end

    describe "dependencies" do
      it "persists rubygem dependencies" do
        do_perform
        dependencies = Rubygem.find(gem_name)
                              .rubygem_dependencies
                              .pluck(:dependency_name, :type, :requirements)

        expect(dependencies).to eq [
          ["rspec-core", "runtime", "~> 3.7.0"],
          ["rspec-expectations", "runtime", "~> 3.7.0"],
          ["rspec-mocks", "runtime", "~> 3.7.0"],
        ]
      end

      it "drops obsolete dependencies" do
        described_class.new.perform gem_name
        RubygemDependency.create! rubygem_name:    gem_name,
                                  dependency_name: "old",
                                  requirements:    ">= 0.1.0",
                                  type:            "development"

        expect { do_perform }.to change { Rubygem.find(gem_name).rubygem_dependencies.pluck(:dependency_name) }
          .from(%w[old rspec-core rspec-expectations rspec-mocks])
          .to(%w[rspec-core rspec-expectations rspec-mocks])
      end
    end

    describe "when rubygems.org is down" do
      let(:gem_name) { "thisisdowninmock" }

      it "raises an exception" do
        expect { do_perform }.to raise_error "Unknown response status 500"
      end
    end

    # Tests for correct date handling when built_at dates are unreliable
    # This mimics real-world scenarios like smarter_csv where:
    # - Version 2.0.0 has built_at of 1980-01-02 (bogus) but was actually released 2026-02-04
    # - Version 1.0.0 has built_at of 2025-05-29 (correct)
    # - Version 0.1.0 has built_at of 2012-07-29 (correct)
    #
    # The correct behavior should use created_at (actual push date to rubygems.org)
    # instead of built_at (gemspec date field which can be bogus/missing)
    describe "when built_at dates are unreliable" do
      let(:gem_name) { "bogus_dates_gem" }

      it "sets first_release_on based on created_at, not built_at" do
        do_perform

        # First release was 0.1.0 on 2012-07-29 (by created_at)
        # NOT 1980-01-02 (bogus built_at from version 2.0.0)
        expect(Rubygem.find(gem_name).first_release_on).to eq Date.new(2012, 7, 29)
      end

      it "sets latest_release_on based on version_created_at from gems API" do
        do_perform

        # Latest release was 2.0.0 on 2026-02-04 (version_created_at)
        # NOT 2025-05-29 (built_at from version 1.0.0)
        expect(Rubygem.find(gem_name).latest_release_on).to eq Date.new(2026, 2, 4)
      end

      it "groups quarterly_release_counts by created_at, not built_at" do
        do_perform

        quarterly_counts = Rubygem.find(gem_name).quarterly_release_counts

        # Version 2.0.0 should be counted in Q1 2026 (created_at: 2026-02-04)
        # NOT in Q1 1980 (bogus built_at: 1980-01-02)
        expect(quarterly_counts).to include("2026-1" => 1)
        expect(quarterly_counts).not_to have_key("1980-1")
      end

      it "does not include releases in quarters before the actual first release" do
        do_perform

        quarterly_counts = Rubygem.find(gem_name).quarterly_release_counts

        # Should only have quarters from 2012 onwards (actual first release)
        # No quarters from 1980
        quarterly_counts.keys.each do |quarter|
          year = quarter.split("-").first.to_i
          expect(year).to be >= 2012
        end
      end
    end
  end
end
