# frozen_string_literal: true

class CreateGithubReadmes < ActiveRecord::Migration[6.0]
  def change
    create_table :github_readmes, id: false do |t|
      t.string :path, null: false
      t.text :html, null: false
      t.string :etag, null: false
      t.timestamps
    end

    add_index :github_readmes, :path, unique: true
  end
end
