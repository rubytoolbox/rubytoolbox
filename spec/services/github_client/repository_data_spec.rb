# frozen_string_literal: true

require "rails_helper"

RSpec.describe GithubClient::RepositoryData, type: :service do
  fixtures :all

  def data(fields = {})
    described_class.new("data" => { "repository" => fields.deep_stringify_keys })
  end

  shared_examples_for "a value dependent on issues being enabled" do |attribute|
    it "is nil if the repo has no data" do
      expect(data.public_send(attribute)).to be_nil
    end

    it "is nil if the repo has data but issues are disabled" do
      repo = data openIssues: { totalCount: 5 }, closedIssues: { totalCount: 10 }
      expect(repo.public_send(attribute)).to be_nil
    end
  end

  describe "#total_issues_count" do
    it_behaves_like "a value dependent on issues being enabled", :total_issues_count

    it "is the sum of issues if issues enabled and data available" do
      repo = data openIssues:       { totalCount: 5 },
                  closedIssues:     { totalCount: 10 },
                  hasIssuesEnabled: true
      expect(repo.total_issues_count).to be == 10 + 5
    end
  end

  describe "#issue_closure_rate" do
    it_behaves_like "a value dependent on issues being enabled", :issue_closure_rate

    it "is the expected float if the repo has data" do
      repo = data openIssues:       { totalCount: 5 },
                  closedIssues:     { totalCount: 10 },
                  hasIssuesEnabled: true
      expect(repo.issue_closure_rate).to be_within(0.00001).of(10 * 100.0 / 15)
    end
  end

  describe "#pull_request_acceptance_rate" do
    it "is nil if PR data is missing" do
      expect(data.pull_request_acceptance_rate).to be_nil
    end

    it "is nil if the repo had no PRs" do
      repo = data openPullRequests:   { totalCount: 0 },
                  mergedPullRequests: { totalCount: 0 },
                  closedPullRequests: { totalCount: 0 }

      expect(repo.pull_request_acceptance_rate).to be_nil
    end

    it "is the expected float if the repo has PR data" do
      repo = data openPullRequests:   { totalCount: 7 },
                  mergedPullRequests: { totalCount: 11 },
                  closedPullRequests: { totalCount: 3 }

      expect(repo.pull_request_acceptance_rate).to be_within(0.00001).of((11 * 100.0) / (7 + 11 + 3))
    end
  end

  describe "#total_pull_requests_count" do
    it "is nil if PR data is missing" do
      expect(data.total_pull_requests_count).to be_nil
    end

    it "is the sum of open, closed and merged PRs" do
      repo = data openPullRequests:   { totalCount: 7 },
                  mergedPullRequests: { totalCount: 11 },
                  closedPullRequests: { totalCount: 3 }

      expect(repo.total_pull_requests_count).to be == 7 + 11 + 3
    end
  end
end
