# frozen_string_literal: true

class AddCheckConstraintOnProjectGemReference < ActiveRecord::Migration[5.1]
  def self.up
    execute <<~SQL.squish
      ALTER TABLE
        projects
      ADD CONSTRAINT
        check_project_permalink_and_rubygem_name_parity
      CHECK (
        rubygem_name IS NULL OR rubygem_name = permalink
      )
    SQL
  end

  def self.down
    execute "ALTER TABLE projects DROP CONSTRAINT check_project_permalink_and_rubygem_name_parity"
  end
end
