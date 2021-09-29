# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Full Project Sync", :clean_database, :real_http, :sidekiq_inline do
  describe "for Rubygem-based projects", vcr: { cassette_name: "full-project-sync-from-gem" } do
    let(:do_perform) { RubygemUpdateJob.perform_async "thread_safe" }

    it "creates the project" do
      expect { do_perform }.to change { Project.where(permalink: "thread_safe").count }.from(0).to(1)
    end

    it "assigns the expected attributes to the resulting project" do
      do_perform
      expect(Project.find("thread_safe")).to have_attributes(
        rubygem_name:                 "thread_safe",
        github_repo_path:             "ruby-concurrency/thread_safe",
        github_repo_stargazers_count: (a_value > 100),
        github_repo_forks_count:      (a_value > 10),
        rubygem_downloads:            (a_value > 10_000_000),
        score:                        100.0
      )
    end
  end

  describe "for github-based projects", vcr: { cassette_name: "full-project-sync-from-github" } do
    let(:do_perform) { ProjectUpdateJob.perform_async "postmodern/chruby" }

    it "creates the project" do
      expect { do_perform }.to change { Project.where(permalink: "postmodern/chruby").count }.from(0).to(1)
    end

    it "assigns the expected attributes to the resulting project" do
      do_perform
      expect(Project.find("postmodern/chruby")).to have_attributes(
        rubygem_name:                 nil,
        github_repo_path:             "postmodern/chruby",
        github_repo_stargazers_count: (a_value > 1500),
        github_repo_forks_count:      (a_value > 100),
        score:                        100.0
      )
    end
  end
end
