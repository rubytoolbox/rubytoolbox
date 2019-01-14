# frozen_string_literal: true

class AddBugfixForkDataToProjects < ActiveRecord::Migration[5.2]
  def change
    change_table :projects, bulk: true do |t|
      t.string :bugfix_fork_of, default: nil
      t.string :bugfix_fork_criteria, array: true, default: [], null: false
      t.boolean :is_bugfix_fork, default: false, null: false
    end

    add_index :projects, :bugfix_fork_of
    add_index :projects, :is_bugfix_fork
  end
end
