# frozen_string_literal: true

class AddMissingIndexOnProjectsGithubRepoPath < ActiveRecord::Migration[6.1]
  def change
    add_index :projects, :github_repo_path
  end
end
