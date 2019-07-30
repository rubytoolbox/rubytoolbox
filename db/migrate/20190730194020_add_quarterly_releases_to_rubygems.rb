# frozen_string_literal: true

class AddQuarterlyReleasesToRubygems < ActiveRecord::Migration[5.2]
  def change
    add_column :rubygems, :quarterly_release_counts, :jsonb, default: {}, null: false
  end
end
