# frozen_string_literal: true

class ChangeDownloadsColumnTypeToBigint < ActiveRecord::Migration[7.1]
  def up
    change_column :rubygems, :downloads, :bigint, null: false
    change_column :rubygem_download_stats, :total_downloads, :bigint, null: false
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
