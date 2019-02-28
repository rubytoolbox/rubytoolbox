# frozen_string_literal: true

#
# This job detects trending projects for a given date
# based on RubygemDownloadStats and persists them in the Rubygem::Trend
# model for easier querying and stable results over time (if the
# calculation changes down the road)
#
class RubygemTrendsJob < ApplicationJob
  def perform(date)
    Rubygem::Trend.transaction do
      Rubygem::Trend.where(date: date).destroy_all
      trending_stats_for(date).each.with_index do |stat, i|
        Rubygem::Trend.create! rubygem:               stat.rubygem,
                               date:                  date,
                               position:              i + 1,
                               rubygem_download_stat: stat
      end
    end
  end

  private

  def trending_stats_for(date)
    RubygemDownloadStat
      .merge(trending_scope)
      .where(date: date)
      .with_associations
      .limit(48)
  end

  def trending_scope
    RubygemDownloadStat
      .where.not(relative_change_month: nil, growth_change_month: nil) # Stats need to be present xD
      .where("absolute_change_month > ?", 10_000) # Baseline minimum downloads to be considered "trending"
      .where("growth_change_month > ?", 0) # Month-over-month growth must be positive to be trending
      .where("rubygems.latest_release_on > ?", 6.months.ago) # Must have had a recent release
      .merge(Project.with_bugfix_forks(false))
      .order(relative_change_month: :desc)
  end
end
