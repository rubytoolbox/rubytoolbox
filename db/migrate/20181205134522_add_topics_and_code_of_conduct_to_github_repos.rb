# frozen_string_literal: true

class AddTopicsAndCodeOfConductToGithubRepos < ActiveRecord::Migration[5.2]
  def change
    change_table :github_repos, bulk: true do |t|
      t.string :code_of_conduct_url
      t.string :code_of_conduct_name

      t.string :topics, array: true, default: [], null: false
    end
  end
end
