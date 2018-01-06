# frozen_string_literal: true

class AddDescriptionToProjectsForSearch < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :description, :text
  end
end
