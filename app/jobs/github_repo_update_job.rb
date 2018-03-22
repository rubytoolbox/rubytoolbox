# frozen_string_literal: true

class GithubRepoUpdateJob < ApplicationJob
  attr_accessor :client
  private :client=

  def initialize(client: GithubClient.new)
    self.client = client
  end

  def perform(path)
    info = fetch_repo_info path

    if info
      GithubRepo.find_or_initialize_by(path: path.downcase).tap do |repo|
        # Set updated at to ensure we flag what we've pulled
        repo.updated_at = Time.current.utc
        repo.update! mapped_attributes(info)
        trigger_project_updates repo.projects.pluck(:permalink)
      end
    else
      GithubRepo.where(path: path).destroy_all
    end
  end

  private

  ATTRIBUTE_MAPPING = {
    archived?: :archived,
    average_recent_committed_at: :average_recent_committed_at,
    closed_issues_count: :closed_issues_count,
    closed_pull_requests_count: :closed_pull_requests_count,
    created_at: :repo_created_at,
    default_branch: :default_branch,
    description: :description,
    fork?: :is_fork,
    forks_count: :forks_count,
    homepage_url: :homepage_url,
    issues?: :has_issues,
    license: :license,
    merged_pull_requests_count: :merged_pull_requests_count,
    mirror?: :is_mirror,
    open_issues_count: :open_issues_count,
    open_pull_requests_count: :open_pull_requests_count,
    primary_language: :primary_language,
    pushed_at: :repo_pushed_at,
    stargazers_count: :stargazers_count,
    watchers_count: :watchers_count,
    wiki?: :has_wiki,
  }.freeze

  def mapped_attributes(info)
    ATTRIBUTE_MAPPING.each_with_object({}) do |(remote_name, local_name), mapped|
      value = info.public_send remote_name
      # Ensure we keep true falses around
      mapped[local_name] = value == false ? false : value.presence
    end
  end

  def fetch_repo_info(path)
    client.fetch_repository path
  rescue GithubClient::UnknownRepoError
    nil
  end

  def trigger_project_updates(project_permalinks)
    project_permalinks.each do |permalink|
      ProjectUpdateJob.perform_async permalink
    end
  end
end
