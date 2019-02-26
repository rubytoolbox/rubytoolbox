# frozen_string_literal: true

class AddCategoriesRankIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :categories, :rank
  end
end
