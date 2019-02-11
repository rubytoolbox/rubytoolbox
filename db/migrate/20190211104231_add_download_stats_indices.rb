# frozen_string_literal: true

class AddDownloadStatsIndices < ActiveRecord::Migration[5.2]
  def change
    add_index :rubygem_download_stats, :date
    add_index :rubygem_download_stats, :total_downloads, order: "DESC NULLS LAST"

    add_index :rubygem_download_stats, :absolute_change_week, order: "DESC NULLS LAST"
    add_index :rubygem_download_stats, :relative_change_week, order: "DESC NULLS LAST"

    add_index :rubygem_download_stats, :absolute_change_month, order: "DESC NULLS LAST"
    add_index :rubygem_download_stats, :relative_change_month, order: "DESC NULLS LAST"

    add_index :rubygem_download_stats, :absolute_change_year, order: "DESC NULLS LAST"
    add_index :rubygem_download_stats, :relative_change_year, order: "DESC NULLS LAST"
  end
end
