# frozen_string_literal: true

class AddMissingIndicesToRubygemDependencies < ActiveRecord::Migration[6.1]
  def change
    add_index :rubygem_dependencies, :rubygem_name
    add_index :rubygem_dependencies, :dependency_name
  end
end
