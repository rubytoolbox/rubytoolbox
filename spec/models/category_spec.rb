# frozen_string_literal: true

require "rails_helper"

RSpec.describe Category, type: :model do
  let(:group) do
    CategoryGroup.create! permalink: "unimportant", name: "unimportant"
  end
  let(:category) do
    Category.create! permalink: "mocking", name: "Mocking Frameworks", category_group: group
  end

  describe ".search" do
    it "can find a matching category" do
      category
      Category.create! permalink: "foo", name: "Foo", category_group: group
      Category.create! permalink: "bar", name: "Bar", category_group: group

      expect(Category.search("mock")).to be == [category]
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
