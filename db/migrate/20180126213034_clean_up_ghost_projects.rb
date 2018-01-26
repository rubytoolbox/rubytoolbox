# frozen_string_literal: true

class CleanUpGhostProjects < ActiveRecord::Migration[5.1]
  # Prior to commit 90d97b9ab630840cb8f8717ad352cb585b76bab9
  # projects were always created on catalog sync if missing. This
  # was due to the fact that the catalog sync was built before the
  # actual syncing of rubygems data. After the rubygems sync was
  # added, there was the possibility to run into edge cases where
  # yanked or long-gone gem would remain in the database. This
  # one-off migration cleans this up.
  def change
    Project.where(rubygem_name: nil, github_repo: nil).destroy_all
  end
end
