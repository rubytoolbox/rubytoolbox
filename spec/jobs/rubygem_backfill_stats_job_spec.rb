# frozen_string_literal: true

require "rails_helper"

RSpec.describe RubygemBackfillStatsJob do
  fixtures :all
  let(:gem_name) { "rspec" }
  let(:download_stats) { instance_double Rubygem::DownloadStat.none.class }

  describe ".bestgems_download_stats(gem_name)" do
    subject(:stats) { described_class.bestgems_download_stats(gem_name) }

    it "returns historical download stats for the requested gem", :vcr do
      expect(stats).to include(
        Date.new(2013, 6, 28) => 9_067_290,
        Date.new(2015, 9, 19) => 28_047_155,
        Date.new(2024, 1, 25) => 744_754_103
      )
    end

    context "when the gem is unknown", :vcr do
      let(:gem_name) { "😅" }

      it { expect { stats }.to raise_error described_class::InvalidResponse, /response_status=404/ }
    end
  end

  describe ".missing_dates(rubygem)" do
    subject(:missing_dates) { described_class.missing_dates rubygem }

    let(:rubygem) { instance_double Rubygem, download_stats: }
    let(:stored_dates) do
      Date.new(2023, 12, 3).step(Date.new(2024, 1, 28), 7).to_a.excluding(*expected_missing)
    end
    let(:expected_missing) { [Date.new(2024, 1, 7), Date.new(2024, 1, 14)] }

    before do
      allow(download_stats).to receive(:pluck).with(:date).and_return stored_dates
    end

    it { is_expected.to eq expected_missing }

    context "when the oldest stats predate Bestgems data availability" do
      let(:stored_dates) do
        Date.new(2013, 5, 12).step(Date.new(2013, 7, 28), 7).to_a.excluding(
          Date.new(2013, 5, 26), # Missing but before bestgems data availability, so we shouldn't get it back
          *expected_missing
        )
      end

      let(:expected_missing) { [described_class::BESTGEMS_START_DATE, Date.new(2013, 7, 21)] }

      it { is_expected.to eq expected_missing }
    end
  end

  describe "#perform" do
    subject(:perform) { described_class.new.perform gem_name }

    let(:missing_dates) { [Date.new(2024, 1, 7), Date.new(2024, 1, 14)] }
    # We assume one of the missing data points is actually also missing on bestgems
    let(:bestgems_data) do
      {
        Date.new(2024, 1, 7) => 1234,
      }
    end
    let(:rubygem) do
      instance_double Rubygem, name: gem_name, download_stats:
    end

    let(:touch_scope) { instance_double Rubygem::DownloadStat.none.class, update_all: nil }

    before do
      allow(Rubygem).to receive(:find).with(gem_name).and_return rubygem
      allow(described_class).to receive(:bestgems_download_stats).with(gem_name).and_return bestgems_data
      allow(described_class).to receive(:missing_dates).with(rubygem).and_return missing_dates

      # Stub those as empty calls so we can safely run the code, and we will make individual expectations
      # in specific examples
      allow(rubygem.download_stats).to receive(:create!)
      allow(rubygem.download_stats).to receive(:where).with(absolute_change_month: nil).and_return(touch_scope)
    end

    it "returns the total number of created records" do
      expect(perform).to eq 1
    end

    it "creates the available, missing record" do
      expect(rubygem.download_stats).to receive(:create!).with(
        date: Date.new(2024, 1, 7), total_downloads: 1234
      )

      perform
    end

    it "causes the database triggers for relevant entries to fire" do
      expect(touch_scope).to receive(:update_all).with rubygem_name: rubygem.name

      perform
    end
  end
end
