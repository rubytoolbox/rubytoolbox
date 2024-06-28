# frozen_string_literal: true

class ChangeDownloadsColumnTypeToBigint < ActiveRecord::Migration[7.1]
  def up
    add_column :rubygems, :bigint_downloads, :bigint
    add_column :rubygem_download_stats, :bigint_total_downloads, :bigint

    # rubocop:disable Rails/SkipsModelValidations
    Rubygem.update_all "bigint_downloads = downloads"
    Rubygem::DownloadStat.update_all "bigint_total_downloads = total_downloads"
    # rubocop:enable Rails/SkipsModelValidations

    remove_column :rubygems, :downloads
    remove_column :rubygem_download_stats, :total_downloads

    rename_column :rubygems, :bigint_downloads, :downloads
    rename_column :rubygem_download_stats, :bigint_total_downloads, :total_downloads

    change_column_null :rubygems, :downloads, false
    change_column_null :rubygem_download_stats, :total_downloads, false

    add_index :rubygem_download_stats, :total_downloads, order: "DESC NULLS LAST", algorithm: :concurrently
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
