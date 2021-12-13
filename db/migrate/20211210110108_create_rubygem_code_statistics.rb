# frozen_string_literal: true

class CreateRubygemCodeStatistics < ActiveRecord::Migration[6.1]
  def change
    create_table :rubygem_code_statistics, id: :uuid do |t|
      t.string :rubygem_name, null: false
      t.string :language, null: false
      t.integer :code, :blanks, :comments, null: false
      t.timestamps

      t.index %i[rubygem_name language], unique: true
      t.foreign_key :rubygems, column: :rubygem_name, primary_key: :name
    end
  end
end
