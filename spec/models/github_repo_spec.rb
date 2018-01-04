# frozen_string_literal: true

require "rails_helper"

RSpec.describe GithubRepo, type: :model do
  def create_repo!(path:, updated_at:)
    GithubRepo.create! path: path,
                       updated_at: updated_at,
                       stargazers_count: 1,
                       watchers_count: 1,
                       forks_count: 1
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
      expect(GithubRepo.new(path: " FoO/BaR ").path).to be == "foo/bar"
    end
  end
end
