# frozen_string_literal: true

class CreateCategoryGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :category_groups, id: false do |t|
      t.string :permalink, null: false
      t.string :name, null: false
      t.text   :description
      t.timestamps
    end

    add_index :category_groups, :permalink, unique: true
  end
end
