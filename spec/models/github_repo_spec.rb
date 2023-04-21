# frozen_string_literal: true

require "rails_helper"

RSpec.describe GithubRepo, type: :model do
  fixtures :all

  def create_repo!(path:, updated_at: 1.day.ago)
    GithubRepo.create! path:,
                       updated_at:,
                       stargazers_count: 1,
                       watchers_count:   1,
                       forks_count:      1
  end

  describe ".update_batch" do
    subject(:scope) { described_class.update_batch.to_sql }

    let(:expected_sql) do
      described_class.where("fetched_at < ? ", 24.hours.ago.utc)
                     .order(fetched_at: :asc)
                     .limit((described_class.count / 24.0).ceil)
                     .to_sql
    end

    around do |example|
      Timecop.freeze Time.current do
        example.run
      end
    end

    it { is_expected.to be == expected_sql }
  end

  describe ".without_projects" do
    before do
      create_repo! path: "foo/linked"
      Project.create! permalink: "foo/linked", github_repo_path: "foo/linked"
      create_repo! path: "foo/orphaned"
    end

    it "contains records without associated projects" do
      expect(described_class.without_projects.pluck(:path)).to be == %w[foo/orphaned]
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

  describe "#blob_url" do
    it "is derived from the repo path and default_branch" do
      expect(described_class.new(path: "foo/bar", default_branch: "main").blob_url).to be == "https://github.com/foo/bar/blob/main"
    end

    it "is nil when there is no default_branch" do
      expect(described_class.new(path: "foo/bar", default_branch: nil).blob_url).to be nil
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

  describe "#sibling_gem_with_most_downloads" do
    it "returns rubygem that has the most downloads and same repo" do
      widget = Factories.project "widget", downloads: 50_000
      other = Factories.project "other", downloads: 10_000
      other.update! github_repo: widget.github_repo

      expect(other.github_repo.sibling_gem_with_most_downloads).to be == widget.rubygem
    end
  end
end
