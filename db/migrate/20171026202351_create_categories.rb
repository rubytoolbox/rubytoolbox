# frozen_string_literal: true

class CreateCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :categories, id: false do |t|
      t.string :permalink, null: false
      t.string :name, null: false
      t.text   :description
      t.timestamps
    end

    add_index :categories, :permalink, unique: true
  end
end
