# frozen_string_literal: true

class ChangeDownloadsColumnTypeToBigint < ActiveRecord::Migration[7.1]
  def up
    # On production, I have performed this migration manually on the rails console
    # against a secondary forked database, which then was promoted to become the new primary.
    #
    # We just want to get the version tracked on the migrations table.
    #
    # See https://github.com/rubytoolbox/rubytoolbox/pull/1366
    return if Rails.env.production?

    change_column :rubygems, :downloads, :bigint, null: false
    change_column :rubygem_download_stats, :total_downloads, :bigint, null: false
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
