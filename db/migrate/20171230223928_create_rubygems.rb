# frozen_string_literal: true

class CreateRubygems < ActiveRecord::Migration[5.1]
  def change
    create_table :rubygems, id: false do |t|
      t.string  :name, null: false
      t.text    :description
      t.integer :downloads, null: false
      t.timestamps
    end

    add_index :rubygems, :name, unique: true
  end
end
