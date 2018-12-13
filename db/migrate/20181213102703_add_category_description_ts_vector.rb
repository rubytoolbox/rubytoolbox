# frozen_string_literal: true

class AddCategoryDescriptionTsVector < ActiveRecord::Migration[5.2]
  # See https://github.com/Casecommons/pg_search/wiki/Building-indexes
  def up
    vector_column = "description_tsvector"
    add_column :categories, vector_column, :tsvector
    add_index :categories, vector_column, using: "gin"

    trigger_name = "categories_update_#{vector_column}_trigger"
    create_trigger(trigger_name, compatibility: 1).on(:categories).before(:insert, :update) do
      "new.#{vector_column} := to_tsvector('pg_catalog.simple', coalesce(new.description, ''));"
    end

    execute "UPDATE categories SET permalink = permalink"
  end

  def down
    remove_column :categories, "description_tsvector"
    drop_trigger "categories_update_description_tsvector_trigger", :categories, compatibility: 1
  end
end
