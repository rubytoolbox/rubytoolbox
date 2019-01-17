# frozen_string_literal: true

class AddIssueAndPrStatsPersistence < ActiveRecord::Migration[5.2]
  def change
    change_table :github_repos, bulk: true do |t|
      t.integer :total_issues_count, default: nil
      t.integer :total_pull_requests_count, default: nil
      t.decimal :issue_closure_rate, default: nil, scale: 2, precision: 5
      t.decimal :pull_request_acceptance_rate, default: nil, scale: 2, precision: 5
    end
  end
end
