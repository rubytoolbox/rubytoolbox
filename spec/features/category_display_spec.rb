# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Categories Display", type: :feature do
  it "can display projects of a category" do
    group = CategoryGroup.create! permalink: "group1", name: "Group"
    category = Category.create! permalink: "widgets", name: "Widgets", category_group: group
    category.projects << Project.create!(permalink: "rspec", score: 25)

    visit "/categories/widgets"
    within ".projects" do
      expect(page).to have_text "rspec"
    end
  end
end
