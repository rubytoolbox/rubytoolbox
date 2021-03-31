# frozen_string_literal: true

class CreateRubygemDependencies < ActiveRecord::Migration[6.1]
  def change
    create_table :rubygem_dependencies do |t|
      t.string :rubygem_name, null: false
      t.foreign_key :rubygems, column: :rubygem_name, primary_key: :name

      t.string :dependency_name, null: false

      t.string :type, null: false
      t.string :requirements

      t.timestamps
    end
  end
end
