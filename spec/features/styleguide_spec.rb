# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Styleguide Display", type: :feature do
  it "can display all pages of the styleguide" do
    group = CategoryGroup.create! permalink: "group1", name: "Group"
    category = Category.create! permalink: "widgets", name: "Widgets", category_group: group
    category.projects << Project.create!(permalink: "rspec", score: 25)

    visit "/pages/components"
    within ".hero" do
      expect(page).to have_text "Ruby Toolbox UI Components Styleguide"
      expect(page).to have_text "Components Overview"
    end

    page_links = page.find_all(".component-list a")
    expect(page_links.size).to be > 0

    page_links.each do |link|
      visit link["href"]
      within ".hero" do
        expect(page).to have_text link.text
      end
    end
  end
end
