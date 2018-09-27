# frozen_string_literal: true

class GithubClient
  # Please write unit tests for me...
  class RepositoryData
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
      Time.zone.at dates.map(&:to_i).sum / dates.count
    end

    private

    def count(key)
      raw_data.dig(key.to_s, "totalCount").presence
    end

    def value(key)
      raw_data.dig(key).presence
    end

    def flag(key)
      !!raw_data.dig(key)
    end

    def time(key)
      Time.zone.parse raw_data.dig(key.to_s).presence
    end
  end
end
