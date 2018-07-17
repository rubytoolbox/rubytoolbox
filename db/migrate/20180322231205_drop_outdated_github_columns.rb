# frozen_string_literal: true

# rubocop:disable Rails/BulkChangeTable - Legacy Migration
class DropOutdatedGithubColumns < ActiveRecord::Migration[5.1]
  def change
    # Removes some columns that are not available or deprecated in github
    # graphql API and have limited value to the toolbox anyway.
    remove_column :github_repos, :has_downloads, type: :boolean
    remove_column :github_repos, :has_pages, type: :boolean
    remove_column :github_repos, :has_projects, type: :boolean
    remove_column :github_repos, :repo_updated_at, type: :datetime
  end
end
# rubocop:enable Rails/BulkChangeTable
