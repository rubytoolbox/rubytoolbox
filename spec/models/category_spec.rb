# frozen_string_literal: true

require "rails_helper"

RSpec.describe Category, type: :model do
  describe ".search" do
    it "can find a matching category" do
      group = CategoryGroup.create! permalink: "unimportant", name: "unimportant"
      expected = Category.create! permalink: "mocking", name: "Mocking Frameworks", category_group: group
      Category.create! permalink: "foo", name: "Foo", category_group: group
      Category.create! permalink: "bar", name: "Bar", category_group: group

      expect(Category.search("mock")).to be == [expected]
    end
  end
end
