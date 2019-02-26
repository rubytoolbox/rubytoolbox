# frozen_string_literal: true

class AddIndexOnCategoriesCreatedAt < ActiveRecord::Migration[5.2]
  def change
    add_index :categories, :created_at
  end
end
