# frozen_string_literal: true

class AddBugfixForkDataToProjects < ActiveRecord::Migration[5.2]
  def change
    change_table :projects, bulk: true do |t|
      t.string :bugfix_fork_of, default: nil
      t.string :bugfix_fork_criteria, array: true, default: [], nil: false
    end

    add_index :projects, :bugfix_fork_of
  end
end
