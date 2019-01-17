# frozen_string_literal: true

class PersistGithubRepoIssueStats < ActiveRecord::Migration[5.2]
  def change
    # Guard clause: Once the deprecated methods get dropped we must not
    # run this code anymore...
    return unless GithubRepo.instance_methods.include? :issue_closure_rate_deprecated

    GithubRepo.find_each do |repo|
      repo.update!(
        total_issues_count:           repo.total_issues_count_deprecated,
        issue_closure_rate:           repo.issue_closure_rate_deprecated,
        total_pull_requests_count:    repo.total_issues_count_deprecated,
        pull_request_acceptance_rate: repo.pull_request_acceptance_rate_deprecated
      )
    end
  end
end
