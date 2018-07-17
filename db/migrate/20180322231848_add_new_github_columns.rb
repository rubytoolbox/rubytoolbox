# frozen_string_literal: true

# rubocop:disable Rails/BulkChangeTable - Legacy Migration
class AddNewGithubColumns < ActiveRecord::Migration[5.1]
  def change
    add_column :github_repos, :primary_language, :string
    add_column :github_repos, :license, :string
    add_column :github_repos, :default_branch, :string

    add_column :github_repos, :is_fork, :boolean
    add_column :github_repos, :is_mirror, :boolean

    add_column :github_repos, :open_issues_count, :integer
    add_column :github_repos, :closed_issues_count, :integer
    add_column :github_repos, :open_pull_requests_count, :integer
    add_column :github_repos, :merged_pull_requests_count, :integer
    add_column :github_repos, :closed_pull_requests_count, :integer

    add_column :github_repos, :average_recent_committed_at, :datetime
  end
end
# rubocop:enable Rails/BulkChangeTable
