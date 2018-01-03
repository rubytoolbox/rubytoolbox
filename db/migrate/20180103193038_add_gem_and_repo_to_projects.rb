# frozen_string_literal: true

class AddGemAndRepoToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :rubygem_name, :string
    add_column :projects, :github_repo_path, :string
    add_index  :projects, :rubygem_name, unique: true
  end
end
