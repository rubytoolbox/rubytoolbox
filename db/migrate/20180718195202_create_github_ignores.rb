# frozen_string_literal: true

class CreateGithubIgnores < ActiveRecord::Migration[5.2]
  def change
    create_table :github_ignores, id: false do |t|
      t.string :path, null: false
      t.timestamps
    end

    add_index :github_ignores, :path, unique: true
  end
end
