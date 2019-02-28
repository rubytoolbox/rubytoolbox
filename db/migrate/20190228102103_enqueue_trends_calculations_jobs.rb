# frozen_string_literal: true

class EnqueueTrendsCalculationsJobs < ActiveRecord::Migration[5.2]
  def up
    Rubygem::DownloadStat.select(:date).distinct.order(date: :desc).pluck(:date).each do |date|
      RubygemTrendsJob.perform_async date
    end
  end

  def down
    Rubygem::Trend.destroy_all
  end
end
