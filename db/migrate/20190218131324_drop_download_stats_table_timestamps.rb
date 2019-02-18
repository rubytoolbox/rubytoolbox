# frozen_string_literal: true

class DropDownloadStatsTableTimestamps < ActiveRecord::Migration[5.2]
  def up
    change_table :rubygem_download_stats, bulk: true do |t|
      t.remove :created_at, :updated_at
    end
  end

  def down
    change_table :rubygem_download_stats, bulk: true, &:timestamps
  end
end
