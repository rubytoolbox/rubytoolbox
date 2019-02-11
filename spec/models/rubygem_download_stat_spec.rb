# frozen_string_literal: true

require "rails_helper"

RSpec.describe RubygemDownloadStat, type: :model do
  let(:rubygem) { Factories.rubygem "example" }

  it "has a unique index on rubygem name and date" do
    do_create = lambda {
      rubygem.download_stats.create! total_downloads: 2000, date: Time.zone.today
    }

    do_create.call

    expect(&do_create).to raise_error(ActiveRecord::RecordNotUnique)
  end

  describe "stats calculation" do
    it "does not calculate any stats when there is no previous record" do
      stat = rubygem.download_stats.create! date: Time.zone.today, total_downloads: 5000
      expect(stat.reload).to have_attributes(
        absolute_change_week:  nil,
        relative_change_week:  nil,
        absolute_change_month: nil,
        relative_change_month: nil,
        absolute_change_year:  nil,
        relative_change_year:  nil
      )
    end

    it "calculates expected stats when there are matching previous records" do # rubocop:disable RSpec/ExampleLength
      rubygem.download_stats.create! date: 52.weeks.ago, total_downloads: 1000
      rubygem.download_stats.create! date: 4.weeks.ago, total_downloads: 3000
      rubygem.download_stats.create! date: 7.days.ago, total_downloads: 5000
      stat = rubygem.download_stats.create! date: Time.zone.today, total_downloads: 6000

      expect(stat.reload).to have_attributes(
        absolute_change_week:  1000,
        relative_change_week:  20.0,
        absolute_change_month: 3000,
        relative_change_month: 100.0,
        absolute_change_year:  5000,
        relative_change_year:  500.0
      )
    end

    it "does not calculate relative changes when the previous downloads were 0" do
      rubygem.download_stats.create! date: 7.days.ago, total_downloads: 0
      stat = rubygem.download_stats.create! date: Time.zone.today, total_downloads: 1000
      expect(stat.reload).to have_attributes(
        absolute_change_week: 1000,
        relative_change_week: nil
      )
    end
  end
end
