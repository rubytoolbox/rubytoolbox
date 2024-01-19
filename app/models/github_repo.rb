# frozen_string_literal: true

class GithubRepo < ApplicationRecord
  self.primary_key = :path

  has_many :projects,
           primary_key: :path,
           foreign_key: :github_repo_path,
           inverse_of:  :github_repo,
           dependent:   :nullify

  has_many :rubygems,
           through: :projects

  has_one :readme,
          primary_key: :path,
          foreign_key: :path,
          inverse_of:  :github_repo,
          class_name:  "Github::Readme",
          dependent:   :destroy

  delegate :html,
           :etag,
           to:        :readme,
           allow_nil: true,
           prefix:    :readme

  scope :update_batch, lambda {
    where("fetched_at < ? ", 24.hours.ago.utc)
      .order(fetched_at: :asc)
      .limit((count / 24.0).ceil)
  }

  def self.without_projects
    joins("LEFT JOIN projects ON projects.github_repo_path = github_repos.path")
      .where(projects: { permalink: nil })
  end

  def path=(path)
    super(Github.normalize_path(path))
  end

  def url
    File.join "https://github.com", path
  end

  def blob_url
    return unless default_branch

    File.join url, "blob", default_branch
  end

  def issues_url
    File.join(url, "issues") if has_issues?
  end

  def pull_requests_url
    File.join(url, "pulls")
  end

  def wiki_url
    File.join(url, "wiki") if has_wiki?
  end

  def sibling_gem_with_most_downloads
    rubygems.order(downloads: :desc).first
  end
end
