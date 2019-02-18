# frozen_string_literal: true

#
# This job performs an upsert to store whatever downloads count is currently stored
# on each rubygem into the historical stats table rubygem_download_stats.
#
# * This job is scheduled hourly
# * It only actually runs on sundays, because we only currently need weekly stats anyway
# * If it already ran on a given day we don't care, we'll keep upserting until the day ends.
#   This is to ensure within reason that the job actually runs on every sunday without having
#   to put in place some complex persistent logic that actually keeps track of that.
#
class RubygemDownloadsPersistenceJob < ApplicationJob
  def perform # rubocop:disable Metrics/MethodLength It's a simple method, the SQL code is just lengthy
    return unless should_run?

    upsert_sql = <<~SQL
      INSERT INTO
        rubygem_download_stats (rubygem_name, total_downloads, date)
        SELECT
          name AS rubygem_name,
          downloads AS total_downloads,
          DATE '#{date}' as date
        FROM   rubygems

      ON CONFLICT (rubygem_name, date) DO UPDATE
      SET
        total_downloads = excluded.total_downloads
    SQL

    result = ActiveRecord::Base.connection.execute upsert_sql
    Rails.logger.info "Processed #{result.cmd_tuples} gem stats records"
    result.cmd_tuples == Rubygem.count
  end

  #
  # We only want to persist weekly stats, with the set date on sundays. Weekly stats
  # are sufficient for the current purposes and reduce the required storage and backup sizes
  # significantly.
  #
  # Since background jobs might be queued on a sunday yet, due to a queue backlog, might get
  # executed at a later time, we need to check this at actual job execution time
  #
  def should_run?
    date.sunday?
  end

  private

  def date
    @date ||= Time.current.utc.to_date
  end
end
