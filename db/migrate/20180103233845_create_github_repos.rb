# frozen_string_literal: true

class CreateGithubRepos < ActiveRecord::Migration[5.1]
  def change
    create_table :github_repos, id: false do |t|
      t.string  :path, null: false
      t.integer :stargazers_count, null: false
      t.integer :forks_count, null: false
      t.integer :watchers_count, null: false

      t.timestamps
    end

    add_index :github_repos, :path, unique: true
  end
end
