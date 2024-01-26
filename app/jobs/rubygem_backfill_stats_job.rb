# frozen_string_literal: true

#
# In case our stats syncing gets stuck we might have some gaps in the data,
# notably this occured in January 2020 when the stats syncing broke due to a
# filled-up queue.
#
# In the case of such gaps, we can rely on bestgems.org for fetching the missing
# data and filling it in. Bestgems was also the original source for most of the
# download data from summer 2013 on when initially released, see the release
# announcement at https://www.ruby-toolbox.com/blog/2019-02-25/historical-gem-download-charts
#
# See also https://github.com/rubytoolbox/rubytoolbox/issues/1194
#
class RubygemBackfillStatsJob < ApplicationJob
  # Bestgems launched mid-2013, so older gaps cannot be backfilled from that source
  # We only store weekly stats on sundays, so we start from a sunday here too.
  BESTGEMS_START_DATE = Date.new 2013, 6, 30

  InvalidResponse = Class.new(StandardError)

  #
  # Fetches daily total downloads from bestgems.org and returns it in date => total_downloads
  # hash format.
  #
  def self.bestgems_download_stats(gem_name)
    response = HTTP.get("https://bestgems.org/api/v1/gems/#{gem_name}/total_downloads.json")
    raise InvalidResponse, "Invalid response_status=#{response.status.to_i}" unless response.status == 200

    Oj.load(response).each_with_object({}) do |entry, hash|
      hash[Date.parse(entry.fetch("date"))] = entry.fetch("total_downloads")
    end
  end

  #
  # Figures out missing dates for download_stats of the given Rubygem model instance
  #
  def self.missing_dates(rubygem)
    stored_dates = rubygem.download_stats.pluck(:date)

    # We take the gem's first stored data date or bestgems data availability date, whichever is later
    start_date = [stored_dates.first, BESTGEMS_START_DATE].max
    end_date = stored_dates.last

    # Expected dates minus those that are stored
    start_date.step(end_date, 7).to_a - stored_dates
  end

  private attr_accessor :rubygem

  def perform(name)
    self.rubygem = Rubygem.find name

    adjusted_count = 0

    missing_dates.each do |date|
      next unless bestgems_data[date]

      rubygem.download_stats.create! date:, total_downloads: bestgems_data[date]
      adjusted_count += 1
    end

    trigger_the_triggers!

    adjusted_count
  end

  private

  def missing_dates
    @missing_dates ||= self.class.missing_dates rubygem
  end

  def bestgems_data
    @bestgems_data ||= self.class.bestgems_download_stats rubygem.name
  end

  # After filling gaps, we must touch all adjacent records so the derived stats get recalculated
  # Since the stats get calculated with a PG trigger function and we don't have timestamps on this
  # table, we have to force-issue an sql-level update statement for the records (i.e. instead of doing
  # an active record `touch`)
  #
  # rubocop:disable Rails/SkipsModelValidations It's fine & intended
  def trigger_the_triggers!
    rubygem.download_stats.where(absolute_change_month: nil).update_all name: rubygem.name
  end
  # rubocop:enable Rails/SkipsModelValidations
end
