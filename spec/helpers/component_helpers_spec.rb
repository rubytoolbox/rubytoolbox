# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComponentHelpers, type: :helper do
  let(:group) do
    CategoryGroup.create! permalink: "unimportant", name: "unimportant"
  end
  let(:category) do
    Category.create! permalink:      "mocking",
                     name:           "Mocking Frameworks",
                     description:    "Widgets Factory",
                     category_group: group
  end

  describe "#category_card" do
    before do
      Factories.project("sample").update! categories: [category]
    end

    it "issues no count db queries" do
      category = Category.includes(:projects).find("mocking")

      expect { helper.category_card(category) }.not_to make_database_queries
    end
  end
end
