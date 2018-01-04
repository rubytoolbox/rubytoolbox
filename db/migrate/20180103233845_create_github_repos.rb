# frozen_string_literal: true

class CreateGithubRepos < ActiveRecord::Migration[5.1]
  def change
    create_table :github_repos, id: false do |t|
      t.string  :path, null: false
      t.integer :stargazers_count,
                :forks_count,
                :watchers_count,
                null: false

      t.string :description,
               :homepage_url

      t.datetime :repo_created_at,
                 :repo_updated_at,
                 :repo_pushed_at

      t.boolean :has_issues,
                :has_projects,
                :has_downloads,
                :has_wiki,
                :has_pages,
                :archived

      t.timestamps
    end

    add_index :github_repos, :path, unique: true
  end
end
