# frozen_string_literal: true

require "rails_helper"

RSpec.describe GithubRepoUpdateJob, type: :job do
  let(:repo_data) do
    json = Rails.root.join("spec", "fixtures", "graphql_responses", "github", "rails.json").read
    GithubClient::RepositoryData.new Oj.load(json)
  end
  let(:faked_github_client) do
    instance_double(GithubClient, fetch_repository: repo_data)
  end

  let(:job) { described_class.new client: faked_github_client }
  let(:do_perform) { job.perform repo_path }
  let(:repo_path) { "rails/rails" }

  describe "#perform" do
    let(:expected_attributes) do
      {
        archived: false,
        average_recent_committed_at: a_value > Time.zone.parse("2018-03-03T22:39:06Z"),
        closed_issues_count: a_value > 10_000,
        closed_pull_requests_count: a_value > 6000,
        default_branch: "master",
        description: "Ruby on Rails",
        forks_count: a_value > 14_000,
        has_issues: true,
        has_wiki: false,
        homepage_url: "http://rubyonrails.org",
        is_fork: false,
        is_mirror: false,
        license: "mit",
        merged_pull_requests_count: a_value > 13_700,
        open_issues_count: a_value > 50,
        open_pull_requests_count: a_value > 100,
        primary_language: "Ruby",
        repo_created_at: Time.zone.parse("2008-04-11T02:19:47Z"),
        repo_pushed_at: a_value > Time.zone.parse("2018-01-03T22:39:06Z"),
        stargazers_count: a_value > 38_140,
        watchers_count: a_value > 2520,
      }
    end

    it "applies the remote attributes" do
      do_perform

      expect(GithubRepo.find(repo_path)).to have_attributes(expected_attributes)
    end

    it "changes the updated_at timestamp regardless of changes" do
      described_class.new(client: faked_github_client).perform repo_path
      GithubRepo.find(repo_path).update! updated_at: 2.days.ago
      expect { do_perform }.to(change { GithubRepo.find(repo_path).updated_at })
    end

    it "enqueues a corresponding project update job" do
      rubygem = Rubygem.create! name: "rails", downloads: 500, current_version: "1.0"
      Project.create! permalink: "rails", github_repo_path: repo_path, rubygem: rubygem
      expect(ProjectUpdateJob).to receive(:perform_async).with("rails")
      do_perform
    end
  end
end
