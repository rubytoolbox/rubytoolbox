# frozen_string_literal: true

require "rails_helper"

RSpec.describe GithubRepoUpdateJob, type: :job do
  let(:job) { described_class.new }
  let(:do_perform) { job.perform repo_path }
  let(:repo_path) { "rails/rails" }

  describe "#perform" do
    let(:expected_attributes) do
      {
        stargazers_count: 38_140,
        watchers_count: 2520,
        forks_count: 15_500,
        description: "Ruby on Rails",
        repo_created_at: Time.zone.parse("2008-04-11T02:19:47Z"),
        repo_updated_at: Time.zone.parse("2018-01-03T21:10:44Z"),
        repo_pushed_at: Time.zone.parse("2018-01-03T22:39:06Z"),
        homepage_url: "http://rubyonrails.org",
        has_issues: true,
        has_projects: true,
        has_downloads: true,
        has_wiki: false,
        has_pages: false,
        archived: false,
      }
    end

    it "applies the remote attributes" do
      do_perform

      expect(GithubRepo.find(repo_path)).to have_attributes(expected_attributes)
    end

    it "changes the updated_at timestamp regardless of changes" do
      described_class.new.perform repo_path
      GithubRepo.find(repo_path).update_attributes! updated_at: 2.days.ago
      expect { do_perform }.to(change { GithubRepo.find(repo_path).updated_at })
    end

    it "enqueues a corresponding project update job" do
      expect(ProjectUpdateJob).to receive(:perform_async).with(repo_path)
      do_perform
    end

    describe "when github is down" do
      let(:repo_path) { "ohnogithub/isdown" }

      it "raises an exception" do
        expect { do_perform }.to raise_error "Unknown response status 500"
      end
    end
  end
end
