# frozen_string_literal: true

class CreateCategorizations < ActiveRecord::Migration[5.1]
  def change
    create_table :categorizations do |t|
      t.string :category_permalink, null: false, index: true
      t.string :project_permalink, null: false, index: true

      t.timestamps
    end

    add_index :categorizations, %i[category_permalink project_permalink],
              unique: true,
              name: :categorizations_unique_index

    add_foreign_key :categorizations, :categories,
                    column: :category_permalink,
                    primary_key: :permalink

    add_foreign_key :categorizations, :projects,
                    column: :project_permalink,
                    primary_key: :permalink
  end
end
