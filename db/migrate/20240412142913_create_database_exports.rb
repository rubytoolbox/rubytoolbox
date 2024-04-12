# frozen_string_literal: true

class CreateDatabaseExports < ActiveRecord::Migration[7.1]
  def change
    create_table :database_exports, &:timestamps
  end
end
