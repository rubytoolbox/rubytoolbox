# frozen_string_literal: true

require "rails_helper"

RSpec.describe GithubRepo, type: :model do
  def create_repo!(path:, updated_at:)
    GithubRepo.create! path:             path,
                       updated_at:       updated_at,
                       stargazers_count: 1,
                       watchers_count:   1,
                       forks_count:      1
  end

  describe ".update_batch" do
    before do
      create_repo! path: "foo/up-to-date", updated_at: 23.hours.ago
      create_repo! path: "foo/outdated1", updated_at: 27.hours.ago
      create_repo! path: "foo/outdated2", updated_at: 26.hours.ago
    end

    it "contains a subset of repos that should be updated" do
      expect(described_class.update_batch).to match %w[foo/outdated1]
    end

    it "the subset grows with to the total count of repos" do
      24.times do |i|
        create_repo! path: "foo/outdated#{i + 3}", updated_at: 25.hours.ago
      end

      expect(described_class.update_batch).to match %w[foo/outdated1 foo/outdated2]
    end
  end

  describe "#path=" do
    it "normalizes the path to the stripped, downcase variant" do
      expect(described_class.new(path: " FoO/BaR ").path).to be == "foo/bar"
    end
  end

  describe "#url" do
    it "is derived from the repo path" do
      expect(described_class.new(path: "foo/bar").url).to be == "https://github.com/foo/bar"
    end
  end

  describe "#wiki_url" do
    it "is nil when has_wiki is false" do
      expect(described_class.new(has_wiki: false).wiki_url).to be_nil
    end

    it "is derived from repo path when has_wiki is true" do
      expected_url = "https://github.com/foo/bar/wiki"
      expect(described_class.new(path: "foo/bar", has_wiki: true).wiki_url).to be == expected_url
    end
  end

  describe "#issues_url" do
    it "is nil when has_issues is false" do
      expect(described_class.new(has_issues: false).issues_url).to be_nil
    end

    it "is derived from repo path when has_issues is true" do
      expected_url = "https://github.com/foo/bar/issues"
      expect(described_class.new(path: "foo/bar", has_issues: true).issues_url).to be == expected_url
    end
  end

  describe "#total_issues_count" do
    it "is nil if the repo has no data" do
      expect(described_class.new.total_issues_count).to be_nil
    end

    it "is nil if the repo has issues disabled" do
      repo = described_class.new(
        closed_issues_count: 10,
        open_issues_count:   5
      )
      expect(repo.total_issues_count).to be_nil
    end

    it "is the sum of issues if issues enabled and data available" do
      repo = described_class.new(
        closed_issues_count: 10,
        open_issues_count:   5,
        has_issues:          true
      )
      expect(repo.total_issues_count).to be == 10 + 5
    end
  end

  describe "#issue_closure_rate" do
    it "is nil if the repo has no data" do
      expect(described_class.new.issue_closure_rate).to be_nil
    end

    it "is nil if the repo has data but issues are disabled" do
      expect(described_class.new(closed_issues_count: 10, open_issues_count: 5).issue_closure_rate).to be_nil
    end

    it "is nil if the repo had no issues" do
      expect(described_class.new(closed_issues_count: 0, open_issues_count: 0).issue_closure_rate).to be_nil
    end

    it "is the expected float if the repo has data" do
      repo = described_class.new(has_issues: true, closed_issues_count: 10, open_issues_count: 5)
      expect(repo.issue_closure_rate).to be == (10 * 100.0 / 15)
    end
  end

  describe "#pull_request_acceptance_rate" do
    it "is nil if PR data is missing" do
      expect(described_class.new.pull_request_acceptance_rate).to be_nil
    end

    it "is nil if the repo had no PRs" do
      repo = described_class.new(
        open_pull_requests_count:   0,
        merged_pull_requests_count: 0,
        closed_pull_requests_count: 0
      )
      expect(repo.pull_request_acceptance_rate).to be_nil
    end

    it "is the expected float if the repo has PR data" do
      repo = described_class.new(
        open_pull_requests_count:   7,
        merged_pull_requests_count: 11,
        closed_pull_requests_count: 3
      )
      expect(repo.pull_request_acceptance_rate).to be == (11 * 100.0) / (7 + 11 + 3)
    end
  end

  describe "#total_pull_requests_count" do
    it "is nil if PR data is missing" do
      expect(described_class.new.total_pull_requests_count).to be_nil
    end

    it "is the sum of open, closed and merged PRs" do
      repo = described_class.new(
        open_pull_requests_count:   7,
        merged_pull_requests_count: 11,
        closed_pull_requests_count: 3
      )
      expect(repo.total_pull_requests_count).to be == 7 + 11 + 3
    end
  end
end
