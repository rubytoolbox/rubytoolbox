# frozen_string_literal: true

require "rails_helper"

RSpec.describe Category, type: :model do
  let(:group) do
    CategoryGroup.create! permalink: "unimportant", name: "unimportant"
  end
  let(:category) do
    Category.create! permalink:      "mocking",
                     name:           "Mocking Frameworks",
                     description:    "Widgets Factory",
                     category_group: group
  end

  describe ".search" do
    it "can find a matching category by name" do
      category
      Category.create! permalink: "foo", name: "Foo", category_group: group
      Category.create! permalink: "bar", name: "Bar", category_group: group

      expect(Category.search("mock")).to be == [category]
    end

    it "can find a matching category by description" do
      category
      expect(Category.search("widget")).to be == [category]
    end

    it "eager-loads associated projects" do
      5.times do |i|
        category = Category.create! name: "widgets #{i}", permalink: i.to_s, category_group: group
        category.projects << Project.create!(permalink: i.to_s)
      end

      scope = Category.search("widgets")
      expect { scope.flat_map { |category| category.projects.map(&:permalink) } } .to make_database_queries(count: 3)
    end
  end

  describe ".by_rank" do
    it "returns only ranked categories, ordered by rank" do
      Category.create! permalink: "A", name: "A", category_group: group
      Category.create! permalink: "B", name: "B", category_group: group, rank: 2
      Category.create! permalink: "C", name: "C", category_group: group, rank: 1

      expect(Category.by_rank.pluck(:permalink)).to be == %w[C B]
    end
  end

  describe ".featured" do
    it "returns up to 16 ranked categories" do
      20.times { |i| Category.create! permalink: (i + 1).to_s, name: (i + 1).to_s, category_group: group, rank: 16 - i }
      Category.create! permalink: "A", name: "A", category_group: group
      expect(Category.featured.pluck(:permalink)).to be == (5..20).to_a.map(&:to_s).reverse
    end
  end

  describe ".recently_added" do
    before do
      5.times do |i|
        Category.create! permalink: (i + 1).to_s, name: (i + 1).to_s, category_group: group, created_at: i.days.ago
      end
    end

    it "returns 4 newest categories" do
      expect(Category.recently_added.pluck(:permalink)).to be == %w[1 2 3 4]
    end

    it "eager-loads projects" do
      query = -> { Category.recently_added.flat_map { |category| category.projects.map(&:permalink) } }
      query.call # warm-up, so activerecord doesn't sprinkle in db schema meta queries
      expect(&query).to make_database_queries(count: 2)
    end
  end

  describe "#catalog_show_url" do
    it "is the url where the category definition can be seen on github" do
      expected = "https://github.com/rubytoolbox/catalog/tree/master/catalog/unimportant/mocking.yml"
      expect(category.catalog_show_url).to be == expected
    end
  end

  describe "#catalog_edit_url" do
    it "is the url where the category definition can be edited on github" do
      expected = "https://github.com/rubytoolbox/catalog/edit/master/catalog/unimportant/mocking.yml"
      expect(category.catalog_edit_url).to be == expected
    end
  end
end
