# frozen_string_literal: true

require "rails_helper"

RSpec.describe Project, type: :model do
  it "does not allow mismatches between permalink and rubygem name" do
    project = Project.create! permalink: "simplecov"
    expect { project.update_attributes! rubygem_name: "rails" }.to raise_error(
      ActiveRecord::StatementInvalid,
      /check_project_permalink_and_rubygem_name_parity/
    )
  end

  describe ".search" do
    it "can find a matching project" do
      expected = Project.create! permalink: "widgets", score: 1
      Project.create! permalink: "airplanes", score: 1
      Project.create! permalink: "rockets", score: 1

      expect(Project.search("widget")).to be == [expected]
    end

    it "does not return projects without a score" do
      expected = Project.create! permalink: "somethingelse", score: 1, description: "Provides amazing widgets"
      Project.create! permalink: "widgets"
      expect(Project.search("widget")).to be == [expected]
    end
  end

  describe "#github_only?" do
    it "is false when no / is present in permalink" do
      expect(Project.new(permalink: "foobar")).not_to be_github_only
    end

    it "is true when a / is present in permalink" do
      expect(Project.new(permalink: "foo/bar")).to be_github_only
    end
  end

  describe "#github_repo_path=" do
    it "normalizes the path to the stripped, downcase variant" do
      expect(Project.new(github_repo_path: " FoO/BaR ").github_repo_path).to be == "foo/bar"
    end
  end

  describe "url delegation" do
    %i[changelog_url documentation_url mailing_list_url].each do |url|
      describe "##{url}" do
        it "is fetched from the rubygem" do
          project = Project.new(rubygem: Rubygem.new(url => "foobar"))
          expect(project.send(url)).to be == "foobar"
        end
      end
    end

    describe "#source_code_url" do
      let(:project) do
        described_class.new(
          rubygem: Rubygem.new(source_code_url: "from_gem"),
          github_repo: GithubRepo.new(path: "foo/bar")
        )
      end

      it "prefers the gem's source code url" do
        expect(project.source_code_url).to be == project.rubygem_source_code_url
      end

      it "falls back to github repo url if not given in gem" do
        project.rubygem.source_code_url = nil
        expect(project.source_code_url).to be == project.github_repo_url
      end
    end

    describe "#homepage_url" do
      let(:project) do
        described_class.new(
          rubygem: Rubygem.new(homepage_url: "from_gem"),
          github_repo: GithubRepo.new(homepage_url: "from_repo")
        )
      end

      it "prefers the gem's homepage url" do
        expect(project.homepage_url).to be == project.rubygem_homepage_url
      end

      it "falls back to github repo homepage url if not given in gem" do
        project.rubygem.homepage_url = nil
        expect(project.homepage_url).to be == project.github_repo_homepage_url
      end
    end

    describe "#wiki_url" do
      let(:project) do
        described_class.new(
          rubygem: Rubygem.new(wiki_url: "from_gem"),
          github_repo: GithubRepo.new(path: "foo/bar")
        )
      end

      it "prefers the gem's wiki url" do
        expect(project.wiki_url).to be == project.rubygem_wiki_url
      end

      it "falls back to github repo wiki url if not given in gem" do
        project.rubygem.wiki_url = nil
        expect(project.wiki_url).to be == project.github_repo_wiki_url
      end
    end

    describe "#bug_tracker_url" do
      let(:project) do
        described_class.new(
          rubygem: Rubygem.new(bug_tracker_url: "from_gem"),
          github_repo: GithubRepo.new(path: "foo/bar")
        )
      end

      it "prefers the gem's bug_tracker_url url" do
        expect(project.bug_tracker_url).to be == project.rubygem_bug_tracker_url
      end

      it "falls back to github repo issues url if not given in gem" do
        project.rubygem.bug_tracker_url = nil
        expect(project.bug_tracker_url).to be == project.github_repo_issues_url
      end
    end
  end

  describe "permalink=" do
    it "normalizes the permalink to the stripped, downcase variant for github repo" do
      expect(Project.new(permalink: " FoO/BaR ").permalink).to be == "foo/bar"
    end

    it "does not normalize the permalink for non-github project" do
      expect(Project.new(permalink: "FoOBaR").permalink).to be == "FoOBaR"
    end
  end
end
