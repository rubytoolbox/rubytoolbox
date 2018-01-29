# frozen_string_literal: true

class AddProjectTsvectorColumns < ActiveRecord::Migration[5.1]
  COLUMNS = %i[permalink description].freeze

  # See https://github.com/Casecommons/pg_search/wiki/Building-indexes
  def up
    COLUMNS.each do |column|
      vector_column = "#{column}_tsvector"
      add_column :projects, vector_column, :tsvector
      add_index :projects, vector_column, using: "gin"

      trigger_name = "projects_update_#{vector_column}_trigger"
      create_trigger(trigger_name, compatibility: 1).on(:projects).before(:insert, :update) do
        "new.#{vector_column} := to_tsvector('pg_catalog.simple', coalesce(new.#{column}, ''));"
      end
    end

    execute "UPDATE projects SET permalink = permalink"
  end

  def down
    COLUMNS.each do |column|
      remove_column :projects, "#{column}_tsvector"
      drop_trigger "projects_update_#{column}_tsvector_trigger", :projects, compatibility: 1
    end
  end
end
