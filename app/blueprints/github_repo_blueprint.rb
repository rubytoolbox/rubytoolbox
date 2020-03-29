# frozen_string_literal: true

class GithubRepoBlueprint < ApplicationBlueprint
  identifier :path

  fields :description,
         :url,
         :wiki_url,
         :primary_language,
         :is_fork,
         :is_mirror,
         :license,
         :repo_pushed_at,
         :average_recent_committed_at

  field :is_archived do |repo, _|
    repo.archived?
  end

  field :stats do |repo|
    {
      stargazers_count: repo.stargazers_count,
      forks_count:      repo.forks_count,
      watchers_count:   repo.watchers_count,
    }
  end

  field :pull_requests do |repo|
    {
      url:             repo.pull_requests_url,
      open_count:      repo.open_pull_requests_count,
      closed_count:    repo.closed_pull_requests_count,
      merged_count:    repo.merged_pull_requests_count,
      total_count:     repo.total_pull_requests_count,
      acceptance_rate: repo.pull_request_acceptance_rate,
    }
  end

  field :issues do |repo|
    if repo.has_issues?
      {
        url:          repo.issues_url,
        open_count:   repo.open_issues_count,
        closed_count: repo.closed_issues_count,
        total_count:  repo.total_issues_count,
        closure_rate: repo.issue_closure_rate,
      }
    end
  end
end
