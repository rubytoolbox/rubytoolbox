# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProjectScoreJob, type: :job do
  let(:job) { described_class.new }

  describe "#perform" do
    def create_repos!
      GithubRepo.create! path: "popular/repo", stargazers_count: 50_000, forks_count: 1_000, watchers_count: 100
      GithubRepo.create! path: "rspec/rspec", stargazers_count: 5_000, forks_count: 100, watchers_count: 100
    end

    def create_gems!
      Rubygem.create! name: "popular", current_version: "1.0", downloads: 1_000_000
      Rubygem.create! name: "rspec", current_version: "1.0", downloads: 500_000,
                      source_code_url: "https://github.com/rspec/rspec"
    end

    it "sets the expected score on projects with rubygem and github repo" do
      create_repos!
      create_gems!
      ProjectUpdateJob.new.perform "rspec"

      expect { job.perform "rspec" }.to change { Project.find("rspec").score }.from(nil).to(30.0)
    end

    it "sets the expected score on projects with just a github repo" do
      create_repos!
      ProjectUpdateJob.new.perform "rspec/rspec"

      expect { job.perform "rspec/rspec" }.to change { Project.find("rspec/rspec").score }.from(nil).to(10.0)
    end

    it "sets the expected score on projects with just a rubygem" do
      create_gems!
      ProjectUpdateJob.new.perform "rspec"

      expect { job.perform "rspec" }.to change { Project.find("rspec").score }.from(nil).to(50.0)
    end

    it "sets the score to nil on projects without anything" do
      Project.create! permalink: "rspec", score: 2.0
      expect { job.perform "rspec" }.to change { Project.find("rspec").score }.to(nil)
    end

    it "sets the bugfix_fork_of to nil" do
      create_gems!
      ProjectUpdateJob.new.perform "rspec"

      expect { job.perform "rspec" }.not_to change { Project.find("rspec").bugfix_fork_of }.from(nil)
    end

    it "sets the bugfix_fork_criteria to an empty array" do
      create_gems!
      ProjectUpdateJob.new.perform "rspec"

      expect { job.perform "rspec" }.not_to change { Project.find("rspec").bugfix_fork_criteria }.from([])
    end

    describe "when bugfix fork criteria apply" do
      let(:detector) do
        instance_double Project::ForkDetector, forked_from: "foobar", fork_criteria: %w[foo bar]
      end

      before do
        create_gems!
        ProjectUpdateJob.new.perform "rspec"
        allow(Project::ForkDetector).to receive(:new)
          .with(Project.find("rspec"))
          .and_return(detector)
      end

      it "sets the bugfix_fork_of to expected value" do
        expect { job.perform "rspec" }.to change { Project.find("rspec").bugfix_fork_of }.to("foobar")
      end

      it "sets the bugfix_fork_criteria to an empty array" do
        expect { job.perform "rspec" }.to change { Project.find("rspec").bugfix_fork_criteria }.to(%w[foo bar])
      end
    end
  end
end
