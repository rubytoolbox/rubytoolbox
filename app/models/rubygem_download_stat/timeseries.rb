# frozen_string_literal: true

#
# This is a utility class for efficiently fetching multiple timeseries for a given
# rubygem name in a single db query and making this data easily usable in a
# chart.js chart.
#
# To reduce the number of datapoints and keep in-browser display performance sane
# only stats every 4 weeks are fetched, using the `RubygemDownloadStat.monthly` scope.
#
class RubygemDownloadStat::Timeseries
  #
  # Just a shorthand for `new(*args).stats`
  #
  def self.fetch(rubygem_name, *requested_stats)
    new(rubygem_name, *requested_stats).stats
  end

  attr_accessor :rubygem_name, :requested_stats
  private :rubygem_name=, :requested_stats=

  def initialize(rubygem_name, *requested_stats)
    self.rubygem_name = rubygem_name
    self.requested_stats = requested_stats
  end

  def stats
    @stats ||= {}.tap do |stats|
      base_query.pluck(:date, *requested_stats).each do |(date, *data)|
        requested_stats.each.with_index do |stat_name, index|
          # We include a baseline data collection date so the x-axis has always the same start date
          stats[stat_name] ||= [{ x: Date.new(2010, 10, 1), y: nil }]
          stats[stat_name] << { x: date, y: data[index] }
        end
      end
    end
  end

  private

  def base_query
    RubygemDownloadStat.where(rubygem_name: rubygem_name).order(date: :asc).monthly
  end
end
