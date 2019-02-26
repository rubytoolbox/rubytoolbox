# frozen_string_literal: true

#
# Utility class for dealing with rubygem download stats navigation:
# Since we only collect weekly stats, this class aids in finding
# the closest present date for any given one and provides helpers
# for timeframe navigation (next year, previous year, previous month etc)
#
class RubygemDownloadStat::Navigation
  #
  # Find the closest matching date in the rubygem download stats dataset
  # (we only have weekly records, so if no exact match is found we will
  # get the closest one) and return it in a class instance
  #
  def self.find(date)
    parsed_date = valid_date(date)

    [
      RubygemDownloadStat.where(date: parsed_date).limit(1),
      RubygemDownloadStat.where("date > ?", parsed_date).order(date: :asc).limit(1),
      RubygemDownloadStat.where("date < ?", parsed_date).order(date: :desc).limit(1),
    ].each do |scope|
      matching_date = scope.pluck(:date).first
      return new(matching_date) if matching_date
    end
  end

  def self.valid_date(date)
    Date.parse date.to_s
  rescue ArgumentError
    RubygemDownloadStat.maximum(:date)
  end

  attr_accessor :date
  private :date=

  def initialize(date)
    self.date = date
  end

  def previous_year
    matching_date(-52.weeks)
  end

  def previous_month
    matching_date(-4.weeks)
  end

  def previous_week
    matching_date(-1.week)
  end

  def next_week
    matching_date(+1.week)
  end

  def next_month
    matching_date(+4.weeks)
  end

  def next_year
    matching_date(+52.weeks)
  end

  private

  def matching_date(distance)
    expected_date = date + distance
    return expected_date if (minimum_available_date..maximum_available_date).cover? expected_date
  end

  def maximum_available_date
    @maximum_available_date ||= RubygemDownloadStat.maximum(:date)
  end

  def minimum_available_date
    @minimum_available_date ||= RubygemDownloadStat.minimum(:date)
  end
end
