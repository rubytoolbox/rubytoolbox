# frozen_string_literal: true

require "rails_helper"

RSpec.describe Project::ForkDetector, type: :model do
  fixtures :all

  let(:detector) { described_class.new(project) }

  describe "for a project that references a significantly more popular gem via it's github repo" do
    let(:rubygem) { instance_double(Rubygem, name: "foo", downloads: 500_000) }

    let(:project) do
      instance_double Project,
                      github_repo_sibling_gem_with_most_downloads: rubygem,
                      rubygem_downloads:                           30,
                      rubygem_description:                         "hello world"
    end

    it "is a fork" do
      expect(detector).to be_fork
    end

    it "has github_sibling in fork_critera" do
      expect(detector.fork_criteria).to be == %w[github_sibling]
    end

    it "references the expected rubygem as forked_from" do
      expect(detector.forked_from).to be == "foo"
    end
  end

  describe "for a project that has the same description as a much more popular gem" do
    let(:project) do
      Rubygem.create! name: "demo", current_version: "1.2", description: "Hello World", downloads: 50_000
      instance_double Project,
                      github_repo_sibling_gem_with_most_downloads: nil,
                      rubygem_downloads:                           1000,
                      rubygem_description:                         "Hello World"
    end

    it "is a fork" do
      expect(detector).to be_fork
    end

    it "has rubygem_sibling in fork_critera" do
      expect(detector.fork_criteria).to be == %w[rubygem_sibling]
    end

    it "references the expected rubygem as forked_from" do
      expect(detector.forked_from).to be == "demo"
    end

    it "isn't a fork when the inspected project has more than 50k downloads" do
      allow(project).to receive(:rubygem_downloads).and_return(50_001)
      expect(detector).not_to be_fork
    end
  end

  describe "for a regular project" do
    let(:project) do
      instance_double Project,
                      github_repo_sibling_gem_with_most_downloads: nil,
                      rubygem_downloads:                           1000,
                      rubygem_description:                         "Hello World"
    end

    it "isn't a fork" do
      expect(detector).not_to be_fork
    end

    it "has empty fork_critera" do
      expect(detector.fork_criteria).to be_empty
    end

    it "has nil as forked_from" do
      expect(detector.forked_from).to be_nil
    end
  end
end
