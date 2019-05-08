# frozen_string_literal: true

class AddFetchedAtTimestamps < ActiveRecord::Migration[5.2]
  def change
    add_column :github_repos, :fetched_at, :datetime
    add_column :rubygems, :fetched_at, :datetime
  end
end
