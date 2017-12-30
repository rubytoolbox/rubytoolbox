# frozen_string_literal: true

class AddCategoriesGroupsAssociation < ActiveRecord::Migration[5.1]
  # This is fine here, we're working on an empty DB
  # rubocop:disable Rails/NotNullColumn:
  def change
    add_column :categories, :category_group_permalink, :string, null: false
    add_index :categories, :category_group_permalink
    add_foreign_key :categories, :category_groups, column: :category_group_permalink, primary_key: :permalink
  end
  # rubocop:enable Rails/NotNullColumn:
end
