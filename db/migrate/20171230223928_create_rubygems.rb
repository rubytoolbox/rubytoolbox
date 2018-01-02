# frozen_string_literal: true

class CreateRubygems < ActiveRecord::Migration[5.1]
  def change
    create_table :rubygems, id: false do |t|
      t.string  :name, null: false
      t.integer :downloads, null: false
      t.string  :current_version, null: false

      t.string  :authors
      t.text    :description
      t.string  :licenses, array: true, default: []

      t.string :bug_tracker_url,
               :changelog_url,
               :documentation_url,
               :homepage_url,
               :mailing_list_url,
               :source_code_url,
               :wiki_url

      t.timestamps
    end

    add_index :rubygems, :name, unique: true
  end
end
