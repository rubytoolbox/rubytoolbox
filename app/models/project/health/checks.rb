# frozen_string_literal: true

module Project::Health::Checks
  GITHUB_REPO_ARCHIVED = Project::Health::Status.new(:github_repo_archived, :red, :github, &:github_repo_archived?)

  GITHUB_REPO_GONE = Project::Health::Status.new(:github_repo_gone, :red, :github) do |project|
    project.github_repo_path? &&
      project.github_repo.nil?
  end

  GITHUB_REPO_NO_COMMIT_ACTIVITY = Project::Health::Status.new(:no_commit_activity, :red, :github) do |project|
    project.github_repo_repo_pushed_at &&
      project.github_repo_repo_pushed_at < 3.years.ago
  end

  GITHUB_REPO_LOW_COMMIT_ACTIVITY = Project::Health::Status.new(:low_commit_activity, :yellow, :github) do |project|
    !GITHUB_REPO_NO_COMMIT_ACTIVITY.applies?(project) &&
      project.github_repo_average_recent_committed_at &&
      project.github_repo_average_recent_committed_at < 3.years.ago
  end

  GITHUB_REPO_OPEN_ISSUES = Project::Health::Status.new(:github_repo_open_issues, :yellow, :github) do |project|
    project.github_repo_total_issues_count &&
      project.github_repo_total_issues_count > 5 &&
      project.github_repo_issue_closure_rate < 75
  end

  RUBYGEM_ABANDONED = Project::Health::Status.new(:rubygem_abandoned, :red, :diamond) do |project|
    project.rubygem_latest_release_on &&
      project.rubygem_latest_release_on < 3.years.ago
  end

  RUBYGEM_STALE = Project::Health::Status.new(:rubygem_stale, :yellow, :diamond) do |project|
    !RUBYGEM_ABANDONED.applies?(project) &&
      project.rubygem_latest_release_on &&
      project.rubygem_latest_release_on < 1.year.ago
  end

  RUBYGEM_LONG_RUNNING = Project::Health::Status.new(:rubygem_long_running, :green, :diamond) do |project|
    project.rubygem_latest_release_on &&
      project.rubygem_first_release_on &&
      project.rubygem_first_release_on < 5.years.ago &&
      project.rubygem_latest_release_on > 1.year.ago
  end

  ALL = [
    GITHUB_REPO_ARCHIVED,
    GITHUB_REPO_GONE,
    GITHUB_REPO_NO_COMMIT_ACTIVITY,
    RUBYGEM_ABANDONED,
    GITHUB_REPO_LOW_COMMIT_ACTIVITY,
    GITHUB_REPO_OPEN_ISSUES,
    RUBYGEM_STALE,
    RUBYGEM_LONG_RUNNING,
  ].freeze
end
