# frozen_string_literal: true

class GithubRepoUpdateJob < ApplicationJob
  attr_accessor :client
  private :client=

  def initialize(client: GithubClient.new)
    super()
    self.client = client
  end

  def perform(path)
    return if GithubIgnore.ignored? path

    info = fetch_repo_info path

    if info
      store_repo path: path, info: info
    else
      GithubRepo.where(path: path).destroy_all
    end
  end

  private

  ATTRIBUTE_MAPPING = {
    archived?:                    :archived,
    average_recent_committed_at:  :average_recent_committed_at,
    closed_issues_count:          :closed_issues_count,
    closed_pull_requests_count:   :closed_pull_requests_count,
    code_of_conduct_name:         :code_of_conduct_name,
    code_of_conduct_url:          :code_of_conduct_url,
    total_issues_count:           :total_issues_count,
    total_pull_requests_count:    :total_pull_requests_count,
    issue_closure_rate:           :issue_closure_rate,
    pull_request_acceptance_rate: :pull_request_acceptance_rate,
    created_at:                   :repo_created_at,
    default_branch:               :default_branch,
    description:                  :description,
    fork?:                        :is_fork,
    forks_count:                  :forks_count,
    homepage_url:                 :homepage_url,
    issues?:                      :has_issues,
    license:                      :license,
    merged_pull_requests_count:   :merged_pull_requests_count,
    mirror?:                      :is_mirror,
    open_issues_count:            :open_issues_count,
    open_pull_requests_count:     :open_pull_requests_count,
    primary_language:             :primary_language,
    pushed_at:                    :repo_pushed_at,
    stargazers_count:             :stargazers_count,
    topics:                       :topics,
    watchers_count:               :watchers_count,
    wiki?:                        :has_wiki,
  }.freeze

  def store_repo(path:, info:)
    GithubRepo.find_or_initialize_by(path: path.downcase).tap do |repo|
      # Set updated at to ensure we flag what we've pulled
      repo.updated_at = repo.fetched_at = Time.current.utc
      repo.update! mapped_attributes(info)

      update_readme_for_repo repo

      trigger_project_updates repo.projects.pluck(:permalink)
    end
  end

  # Put it in a constant so we don't have to re-initialize the array all the time
  FALSY_VALUES = [false, []].freeze

  def mapped_attributes(info)
    ATTRIBUTE_MAPPING.each_with_object({}) do |(remote_name, local_name), mapped|
      value = info.public_send remote_name
      # Ensure we keep true falses and empty arrays around
      mapped[local_name] = FALSY_VALUES.include?(value) ? value : value.presence
    end
  end

  def fetch_repo_info(path)
    client.fetch_repository path
  rescue GithubClient::UnknownRepoError
    GithubIgnore.track! path
    nil
  end

  def update_readme_for_repo(repo) # rubocop:disable Metrics/MethodLength
    readme = client.fetch_readme repo.path, etag: repo.readme_etag

    if readme
      Github::Readme.find_or_initialize_by(path: repo.path).update!(
        html: readme.html,
        etag: readme.etag
      )
    else
      Github::Readme.where(path: repo.path).destroy_all
    end
  rescue GithubClient::CacheHit
    Rails.logger.info "Hit cache for #{repo.path} README, nothing to do"
  end

  def trigger_project_updates(project_permalinks)
    project_permalinks.each do |permalink|
      ProjectUpdateJob.perform_async permalink
    end
  end
end
