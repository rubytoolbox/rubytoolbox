# frozen_string_literal: true

require "rails_helper"

RSpec.describe CatalogImport do
  let(:catalog_data) { Oj.load Rails.root.join("lib", "base-catalog.json").read }

  let(:category_data) { catalog_data["category_groups"].map { |g| g["categories"] }.flatten }

  let(:project_permalinks) { %w[clockwork sidekiq swirrl/taskit willian/has_paginate] }

  let(:import) { described_class.new(catalog_data) }

  before do
    Project.create! permalink: "clockwork"
    Project.create! permalink: "swirrl/taskit"
    Project.create! permalink: "sidekiq"
  end

  describe "perform" do
    it "creates all category groups" do
      expect { import.perform }.to change(CategoryGroup, :count).to(catalog_data["category_groups"].count)
    end

    it "results in expected set of category groups" do
      import.perform
      actual = CategoryGroup.pluck(:permalink)
      expected = catalog_data["category_groups"].map { |g| g["permalink"] }
      expect(actual).to contain_exactly(*expected)
    end

    it "applies expected attributes to imported category groups" do
      import.perform
      group_data = catalog_data["category_groups"].sample
      expect(CategoryGroup.find(group_data["permalink"]))
        .to have_attributes group_data.slice("name", "permalink", "description")
    end

    it "removes obsolete category groups" do
      obsolete_group = CategoryGroup.create! permalink: "Obsolete", name: "Obsolete"

      expect { import.perform }.to change { CategoryGroup.find_by(permalink: obsolete_group.permalink) }.to(nil)
    end

    it "creates all categories" do
      expect { import.perform }.to change(Category, :count).to(category_data.count)
    end

    it "results in expected set of categories" do
      import.perform
      actual = Category.pluck(:permalink)
      expected = category_data.map { |c| c["permalink"] }
      expect(actual).to contain_exactly(*expected)
    end

    it "applies expected attributes to imported categories" do
      import.perform
      sample_data = category_data.sample
      expect(Category.find(sample_data["permalink"]))
        .to have_attributes sample_data.slice("name", "permalink", "description")
    end

    it "removes obsolete categories" do
      import.perform

      obsolete_category = Category.create! permalink:      "Obsolete",
                                           name:           "Obsolete",
                                           category_group: CategoryGroup.first

      expect { import.perform }.to change { Category.find_by(permalink: obsolete_category.permalink) }.to(nil)
    end

    it "creates missing github-based project" do
      expect { import.perform }.to change(Project, :count).by(1)
    end

    it "results in expected set of projects" do
      import.perform
      expect(Project.pluck(:permalink)).to contain_exactly(*project_permalinks)
    end

    it "assigns projects to all of their categories" do
      import.perform
      expect(Project.all.map { |p| p.categories.count }).to all(be > 0)
    end

    it "removes categorizations from existing categorized projects" do
      import.perform
      project = Project.create! permalink: "foo_project", categories: [Category.first]

      expect { import.perform }.to change { project.categories.count }.from(1).to(0)
    end
  end
end
