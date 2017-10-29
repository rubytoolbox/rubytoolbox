# frozen_string_literal: true

class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects, id: false do |t|
      t.string :permalink, null: false
      t.timestamps
    end

    add_index :projects, :permalink, unique: true
  end
end
