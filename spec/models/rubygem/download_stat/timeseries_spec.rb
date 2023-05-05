# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/ExampleLength Data-heavy stuff, and I prefer readability over brevity on those
RSpec.describe Rubygem::DownloadStat::Timeseries do
  fixtures :all

  let(:rubygem) { Factories.rubygem "example" }

  before do
    rubygem.download_stats.create! date: 12.weeks.ago, total_downloads: 1000
    rubygem.download_stats.create! date: 8.weeks.ago, total_downloads: 2000
    rubygem.download_stats.create! date: 4.weeks.ago, total_downloads: 3000
    rubygem.download_stats.create! date: 1.week.ago, total_downloads: 3750
    rubygem.download_stats.create! date: Time.current, total_downloads: 4000
  end

  describe ".fetch" do
    it "is a shorthand for initialize and stats calls" do
      double = instance_double described_class, stats: "Hello World"
      allow(described_class).to receive(:new).with("foo", :bar, :baz).and_return(double)
      expect(described_class.fetch("foo", :bar, :baz)).to be == double.stats
    end
  end

  describe "#stats" do
    let(:timeseries) do
      described_class.new(rubygem.name, :total_downloads, :absolute_change_month)
    end

    it "returns a hash containing expected data" do
      expect(timeseries.stats).to be == {
        total_downloads:       [
          { x: Date.new(2010, 10, 1), y: nil },
          { x: 12.weeks.ago.to_date, y: 1000 },
          { x: 8.weeks.ago.to_date, y: 2000 },
          { x: 4.weeks.ago.to_date, y: 3000 },
          { x: Time.current.to_date, y: 4000 },
        ],
        absolute_change_month: [
          { x: Date.new(2010, 10, 1), y: nil },
          { x: 12.weeks.ago.to_date, y: nil },
          { x: 8.weeks.ago.to_date, y: 1000 },
          { x: 4.weeks.ago.to_date, y: 1000 },
          { x: Time.current.to_date, y: 1000 },
        ],
      }
    end

    it "makes a single database query" do
      expect { timeseries.stats }.to make_database_queries(matching: "SELECT \"rubygem_download_stats\"", count: 1)
    end

    # rubocop:disable RSpec/IdenticalEqualityAssertion
    it "memoizes the calculated stats" do
      expect(timeseries.stats.object_id).to be == timeseries.stats.object_id
    end
    # rubocop:enable RSpec/IdenticalEqualityAssertion
  end
end
# rubocop:enable RSpec/ExampleLength
