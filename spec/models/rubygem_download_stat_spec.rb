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

  # rubocop:disable RSpec/ExampleLength data-heavy examples...
  describe "stats calculation" do
    it "does not calculate any stats when there is no previous record" do
      stat = rubygem.download_stats.create! date: Time.zone.today, total_downloads: 5000
      expect(stat.reload).to have_attributes(
        absolute_change_month: nil,
        relative_change_month: nil,
        growth_change_month:   nil
      )
    end

    it "calculates expected stats when there are matching previous records" do
      {
        104.weeks => 500, # For growth change
        52.weeks  => 1000, # For absolute and relative change
        8.weeks   => 2500, # For growth change
        4.weeks   => 3000, # For absolute and relative change
        2.weeks   => 3000, # For growth change
        1.week    => 5000, # For absolute and relative change
      }.each do |time, downloads|
        rubygem.download_stats.create! date: time.ago, total_downloads: downloads
      end

      current_stat = rubygem.download_stats.create! date: Time.zone.today, total_downloads: 6000

      expect(current_stat.reload).to have_attributes(
        absolute_change_month: 3000,
        relative_change_month: 100.0,
        growth_change_month:   80.0
      )
    end

    it "does not calculate relative changes when the previous downloads were 0" do
      rubygem.download_stats.create! date: 4.weeks.ago, total_downloads: 0
      stat = rubygem.download_stats.create! date: Time.zone.today, total_downloads: 1000
      expect(stat.reload).to have_attributes(
        absolute_change_month: 1000,
        relative_change_month: nil
      )
    end
  end
  # rubocop:enable RSpec/ExampleLength data-heavy examples...
end
