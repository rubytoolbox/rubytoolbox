# frozen_string_literal: true

require "rails_helper"

RSpec.describe Project::ForkDetector, type: :model do
  describe "#fork?" do
    it "is true for a project that references a significantly more popular repo" do
      project = instance_double Project,
                                github_repo_maximum_sibling_downloads: 500_000,
                                rubygem_downloads:                     30,
                                rubygem_description:                   "hello world"

      expect(described_class.new(project)).to be_fork
    end

    it "is true for a project that has the same description as a much more popular gem" do
      Rubygem.create! name: "demo", current_version: "1.2", description: "Hello World", downloads: 50_000
      project = instance_double Project,
                                github_repo_maximum_sibling_downloads: 10,
                                rubygem_downloads:                     1000,
                                rubygem_description:                   "Hello World"

      expect(described_class.new(project)).to be_fork
    end

    it "is false for regular project" do
      project = instance_double Project,
                                github_repo_maximum_sibling_downloads: 1000,
                                rubygem_downloads:                     1000,
                                rubygem_description:                   "Hello World"

      expect(described_class.new(project)).not_to be_fork
    end
  end
end
