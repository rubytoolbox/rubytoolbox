# frozen_string_literal: true

class AddCategoryTsVectorColumn < ActiveRecord::Migration[5.1]
  # See https://github.com/Casecommons/pg_search/wiki/Building-indexes
  def up
    vector_column = "name_tsvector"
    add_column :categories, vector_column, :tsvector
    add_index :categories, vector_column, using: "gin"

    trigger_name = "categories_update_#{vector_column}_trigger"
    create_trigger(trigger_name, compatibility: 1).on(:categories).before(:insert, :update) do
      "new.#{vector_column} := to_tsvector('pg_catalog.simple', coalesce(new.name, ''));"
    end

    execute "UPDATE categories SET permalink = permalink"
  end

  def down
    remove_column :categories, "name_tsvector"
    drop_trigger "projects_update_name_tsvector_trigger", :categories, compatibility: 1
  end
end
