# frozen_string_literal: true

class GithubClient
  # Please write unit tests for me...
  class RepositoryData # rubocop:disable Metrics/ClassLength
    attr_accessor :raw_data
    private :raw_data=

    def initialize(raw_data)
      self.raw_data = raw_data.dig("data", "repository")
    end

    def path
      value "nameWithOwner"
    end

    def description
      value "description"
    end

    def homepage_url
      value "homepageUrl"
    end

    def primary_language
      raw_data.dig("primaryLanguage", "name").presence
    end

    def license
      raw_data.dig("licenseInfo", "key").presence
    end

    def issues?
      flag "hasIssuesEnabled"
    end

    def wiki?
      flag "hasWikiEnabled"
    end

    def archived?
      flag "isArchived"
    end

    def fork?
      flag "isFork"
    end

    def mirror?
      flag "isMirror"
    end

    def forks_count
      count "forks"
    end

    def stargazers_count
      count "stargazers"
    end

    def watchers_count
      count "watchers"
    end

    def open_issues_count
      count "openIssues"
    end

    def closed_issues_count
      count "closedIssues"
    end

    def merged_pull_requests_count
      count "mergedPullRequests"
    end

    def open_pull_requests_count
      count "openPullRequests"
    end

    def closed_pull_requests_count
      count "closedPullRequests"
    end

    def total_issues_count
      return unless issues?

      sum open_issues_count, closed_issues_count
    end

    def issue_closure_rate
      return if !issues? || total_issues_count.nil? || total_issues_count.zero?

      (closed_issues_count * 100.0) / (open_issues_count + closed_issues_count)
    end

    def total_pull_requests_count
      sum open_pull_requests_count, merged_pull_requests_count, closed_pull_requests_count
    end

    def pull_request_acceptance_rate
      return if total_pull_requests_count.nil? || total_pull_requests_count.zero?

      (merged_pull_requests_count * 100.0) / total_pull_requests_count
    end

    def default_branch
      raw_data.dig("defaultBranchRef", "name").presence
    end

    def created_at
      time "createdAt"
    end

    def pushed_at
      time "pushedAt"
    end

    def average_recent_committed_at
      edges = raw_data.dig("defaultBranchRef", "target", "history", "edges")
      # Yip, sometimes published gems reference an empty github repo
      return unless edges

      dates = edges.map { |edge| Time.zone.parse edge.dig("node", "authoredDate") }
      Time.zone.at dates.sum(&:to_i) / dates.count
    end

    def topics
      edges = raw_data.dig("repositoryTopics", "nodes") || []
      edges.map { |topic| topic.dig("topic", "name") }.sort
    end

    def code_of_conduct_name
      raw_data.dig("codeOfConduct", "name").presence
    end

    def code_of_conduct_url
      raw_data.dig("codeOfConduct", "url").presence
    end

    private

    def count(key)
      raw_data.dig(key.to_s, "totalCount").presence
    end

    def value(key)
      raw_data[key].presence
    end

    def flag(key)
      !!raw_data[key]
    end

    def sum(*values)
      return if values.any?(&:nil?)

      values.sum
    end

    def time(key)
      value = raw_data[key.to_s].presence
      return unless value

      Time.zone.parse value
    end
  end
end
