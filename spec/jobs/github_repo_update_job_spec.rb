# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe GithubRepoUpdateJob, type: :job do
  fixtures :all

  let(:repo_data) do
    json = Rails.root.join("spec", "fixtures", "graphql_responses", "github", "rails.json").read
    GithubClient::RepositoryData.new Oj.load(json)
  end
  let(:readme_data) do
    GithubClient::ReadmeData.new("<strong>Hello World</strong>", "ab1234")
  end
  let(:faked_github_client) do
    instance_double(GithubClient, fetch_repository: repo_data, fetch_readme: readme_data)
  end

  let(:job) { described_class.new client: faked_github_client }
  let(:repo_path) { "rails/rails" }

  def do_perform
    job.perform repo_path
  end

  describe "#perform" do
    let(:expected_attributes) do
      {
        archived:                     false,
        average_recent_committed_at:  a_value > Time.zone.parse("2018-03-03T22:39:06Z"),
        closed_issues_count:          a_value > 10_000,
        closed_pull_requests_count:   a_value > 6000,
        code_of_conduct_name:         "Other",
        code_of_conduct_url:          a_string_including("CODE_OF_CONDUCT"),
        default_branch:               "main",
        description:                  "Ruby on Rails",
        forks_count:                  a_value > 14_000,
        has_issues:                   true,
        has_wiki:                     false,
        homepage_url:                 "https://rubyonrails.org",
        is_fork:                      false,
        is_mirror:                    false,
        issue_closure_rate:           a_value > 10,
        license:                      "mit",
        merged_pull_requests_count:   a_value > 13_700,
        open_issues_count:            a_value > 50,
        open_pull_requests_count:     a_value > 100,
        primary_language:             "Ruby",
        pull_request_acceptance_rate: a_value > 10,
        repo_created_at:              Time.zone.parse("2008-04-11T02:19:47Z"),
        repo_pushed_at:               a_value > Time.zone.parse("2018-01-03T22:39:06Z"),
        stargazers_count:             a_value > 38_140,
        topics:                       a_collection_including("rails", "mvc", "html"),
        total_issues_count:           a_value > 10_000,
        total_pull_requests_count:    a_value > 15_000,
        watchers_count:               a_value > 2520,
      }
    end

    it "applies the remote attributes" do
      do_perform

      expect(GithubRepo.find(repo_path)).to have_attributes(expected_attributes)
    end

    it "does not update an ignored repo" do
      GithubIgnore.track! repo_path
      expect(GithubRepo).not_to receive(:find_or_initialize_by)
      do_perform
    end

    it "changes the updated_at timestamp regardless of changes" do
      described_class.new(client: faked_github_client).perform repo_path
      GithubRepo.find(repo_path).update! updated_at: 2.days.ago
      expect { do_perform }.to(change { GithubRepo.find(repo_path).updated_at })
    end

    it "enqueues a corresponding project update job" do
      rubygem = Rubygem.create! name: "rails", downloads: 500, current_version: "1.0"
      Project.create!(permalink: "rails", github_repo_path: repo_path, rubygem:)
      expect(ProjectUpdateJob).to receive(:perform_async).with("rails")
      do_perform
    end

    it "creates a GithubIgnore record when the repo is nowhere to be found" do
      allow(faked_github_client).to receive(:fetch_repository)
        .with(repo_path)
        .and_raise(GithubClient::UnknownRepoError)

      expect { do_perform }
        .to change { GithubIgnore.where(path: repo_path).count }
        .from(0)
        .to(1)
    end

    it "creates readme record" do
      do_perform

      expect(GithubRepo.find(repo_path).readme)
        .to be_a(Github::Readme)
        .and have_attributes(
          html: readme_data.html,
          etag: readme_data.etag
        )
    end

    describe "when no readme is returned" do
      let(:readme_data) { nil }

      it "does not create readme record" do
        expect { do_perform }.not_to change { Github::Readme.find_by(path: repo_path) }.from(nil)
      end

      it "drops existing readme record if gone" do
        do_perform
        Github::Readme.create! path: repo_path, html: "123", etag: "123"

        expect { do_perform }.to change { Github::Readme.find_by(path: repo_path) }.to(nil)
      end
    end

    describe "when cache is hit" do
      before do
        allow(faked_github_client).to receive(:fetch_readme).and_raise GithubClient::CacheHit
      end

      it "keeps around existing readme record" do
        do_perform
        readme = Github::Readme.create! path: repo_path, html: "123", etag: "123"

        expect { do_perform }.not_to change { Github::Readme.find_by(path: repo_path) }.from(readme)
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
