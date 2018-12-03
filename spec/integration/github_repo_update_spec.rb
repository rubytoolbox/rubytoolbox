# frozen_string_literal: true

require "rails_helper"

RSpec.describe GithubRepoUpdateJob, :real_http do
  let(:job) { described_class.new }
  let(:do_perform) { job.perform repo_path }

  describe "for existing repo", vcr: { cassette_name: "rails/rails" } do
    let(:repo_path) { "rails/rails" }

    shared_examples_for "a github repo data update" do
      it "stores the data locally" do
        do_perform
        expect(GithubRepo.find(repo_path)).to have_attributes(
          stargazers_count: (a_value > 30_000),
          watchers_count:   (a_value > 1000),
          forks_count:      (a_value > 10_000)
        )
      end
    end

    describe "which exists locally" do
      it_behaves_like "a github repo data update"
    end

    describe "which does not exist locally" do
      it "creates a new record" do
        expect { do_perform }.to change(GithubRepo, :count).by(1)
      end

      it_behaves_like "a github repo data update"
    end
  end

  describe "for non-existent repo", vcr: { cassette_name: "rails/unknown_repo" } do
    let(:repo_path) { "rails/unknown" }

    describe "which exists locally" do
      it "deletes the local record" do
        GithubRepo.create! path: repo_path, stargazers_count: 5, watchers_count: 5, forks_count: 5
        expect { do_perform }.to change(GithubRepo, :count).by(-1)
      end
    end

    describe "which does not exist locally" do
      it "does not create a record" do
        expect { do_perform }.not_to(change(GithubRepo, :count))
      end
    end
  end
end
