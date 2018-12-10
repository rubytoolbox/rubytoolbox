# frozen_string_literal: true

class AddRankToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :rank, :integer, default: nil
  end
end
