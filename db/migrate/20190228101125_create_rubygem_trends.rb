# frozen_string_literal: true

class CreateRubygemTrends < ActiveRecord::Migration[5.2]
  def change
    create_table :rubygem_trends do |t|
      t.date :date, null: false
      t.string :rubygem_name, null: false
      t.integer :position, null: false
      t.integer :rubygem_download_stat_id, null: false

      t.timestamps
    end

    add_index :rubygem_trends, :date
    add_index :rubygem_trends, :position
    add_index :rubygem_trends, %i[date position], unique: true

    add_foreign_key :rubygem_trends, :rubygems, column: :rubygem_name, primary_key: :name
    add_foreign_key :rubygem_trends, :rubygem_download_stats
  end
end
