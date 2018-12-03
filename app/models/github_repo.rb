# frozen_string_literal: true

class GithubRepo < ApplicationRecord
  self.primary_key = :path

  has_many :projects,
           primary_key: :path,
           foreign_key: :github_repo_path,
           inverse_of:  :github_repo,
           dependent:   :nullify

  def self.update_batch
    where("updated_at < ? ", 24.hours.ago.utc)
      .order(updated_at: :asc)
      .limit((count / 24.0).ceil)
      .pluck(:path)
  end

  def path=(path)
    super Github.normalize_path(path)
  end

  def url
    File.join "https://github.com", path
  end

  def issues_url
    File.join(url, "issues") if has_issues?
  end

  def wiki_url
    File.join(url, "wiki") if has_wiki?
  end

  def total_issues_count
    return if !has_issues? || [open_issues_count, closed_issues_count].any?(&:nil?)

    closed_issues_count + open_issues_count
  end

  def issue_closure_rate
    return if !has_issues? || total_issues_count.nil? || total_issues_count.zero?

    (closed_issues_count * 100.0) / (open_issues_count + closed_issues_count)
  end

  def pull_request_acceptance_rate
    return if total_pull_requests_count.nil? || total_pull_requests_count.zero?

    (merged_pull_requests_count * 100.0) / total_pull_requests_count
  end

  def total_pull_requests_count
    return if [open_pull_requests_count, merged_pull_requests_count, closed_pull_requests_count].any?(&:nil?)

    open_pull_requests_count + merged_pull_requests_count + closed_pull_requests_count
  end
end
