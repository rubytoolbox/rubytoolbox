# frozen_string_literal: true

class CreateRubygemDownloadStats < ActiveRecord::Migration[5.2]
  def change
    create_table :rubygem_download_stats do |t|
      t.string :rubygem_name, null: false
      t.date :date, null: false
      t.integer :total_downloads, null: false
      t.timestamps
    end

    add_index :rubygem_download_stats, %i[rubygem_name date], unique: true
    add_foreign_key :rubygem_download_stats, :rubygems, column: :rubygem_name, primary_key: :name
  end
end
