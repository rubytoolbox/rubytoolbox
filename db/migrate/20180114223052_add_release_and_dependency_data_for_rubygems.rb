# frozen_string_literal: true

class AddReleaseAndDependencyDataForRubygems < ActiveRecord::Migration[5.1]
  def change
    add_column :rubygems, :first_release_on, :date
    add_column :rubygems, :latest_release_on, :date
    add_column :rubygems, :releases_count, :integer
    add_column :rubygems, :reverse_dependencies_count, :integer
  end
end
