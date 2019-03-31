# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Styleguide Display", type: :feature do
  it "can display all pages of the styleguide" do
    group = CategoryGroup.create! permalink: "group1", name: "Group"
    category = Category.create! permalink: "widgets", name: "Widgets", category_group: group
    category.projects << Factories.project("rspec", score: 25)

    visit "/pages/components"
    expect(page).to have_text "Ruby Toolbox UI Components Styleguide"
    expect(page).to have_text "Components Overview"

    page_links = page.find_all(".component-list a").map { |a| [a["href"], a.text] }.to_h
    expect(page_links.size).to be > 0

    page_links.each do |href, text|
      visit "/pages/components"
      visit href
      expect(page).to have_text text
    end
  end
end
