# frozen_string_literal: true

class AddScoreToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :score, :decimal, precision: 5, scale: 2
  end
end
