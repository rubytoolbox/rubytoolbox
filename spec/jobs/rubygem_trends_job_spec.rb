# frozen_string_literal: true

require "rails_helper"

RSpec.describe RubygemTrendsJob, type: :job do
  let(:job) { described_class.new }
  let(:do_perform) { job.perform date }
  let(:date) { Time.current.to_date }

  describe "#perform" do
    it "cleans the database for given date" do
      Factories.rubygem "a"
      Factories.rubygem_trend "a", date: Time.current, position: 1
      Factories.rubygem_trend "a", date: 1.week.ago, position: 1

      expect { do_perform }
        .to change { Rubygem::Trend.select(:date).distinct.pluck(:date) }
        .from([Time.current.to_date, 1.week.ago.to_date])
        .to([1.week.ago.to_date])
    end

    # rubocop:disable RSpec/ExampleLength
    # It's not perfect this way but at least all of the trends logic is
    # in a single place
    it "persists entries for trending projects" do
      Factories.project "a"
      Factories.project "b"
      Factories.project "c"

      Factories.rubygem_download_stat "a", date: 8.weeks.ago, total_downloads: 10_000
      Factories.rubygem_download_stat "a", date: 4.weeks.ago, total_downloads: 30_000
      Factories.rubygem_download_stat "a", date: Time.current, total_downloads: 100_000

      Factories.rubygem_download_stat "c", date: 8.weeks.ago, total_downloads: 1_000
      Factories.rubygem_download_stat "c", date: 4.weeks.ago, total_downloads: 5_000
      Factories.rubygem_download_stat "c", date: Time.current, total_downloads: 50_000

      expect { do_perform }
        .to change { Rubygem::Trend.where(date: date).order(position: :asc).pluck(:rubygem_name) }
        .from([])
        .to(%w[c a])
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
