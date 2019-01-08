# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Search", type: :feature, js: true do
  before do
    group = CategoryGroup.create! permalink: "group1", name: "Group"
    Category.create! permalink: "widgets", name: "Widgets", category_group: group

    Factories.project("widgets", score: 25, downloads: 125_000, first_release: 3.years.ago)
    Factories.project("more widgets",
                      score:         25,
                      description:   "widgets widgets",
                      downloads:     50_000,
                      first_release: 5.years.ago)
    Factories.project("other", score: 22, downloads: 10_000, first_release: 5.years.ago)
  end

  it "allows users to search for projects and categories" do
    search_for "widget"

    expect(listed_project_names).to be == ["more widgets", "widgets"]

    within ".category-card" do
      expect(page).to have_text "Widgets"
    end
  end

  it "can apply a custom project order" do
    search_for "widget"

    expect(listed_project_names).to be == ["more widgets", "widgets"]

    %w[Downloads Stars Forks].each do |button_label|
      within ".project-order-dropdown" do
        page.find("button").hover
        click_on button_label
        expect(page).to have_text "Order by #{button_label}"
      end
      expect(listed_project_names).to be == ["widgets", "more widgets"]
    end

    within ".project-order-dropdown" do
      page.find("button").hover
      click_on "First release"
    end

    within ".project-order-dropdown" do
      expect(page).to have_text "Order by First release"
    end
    expect(listed_project_names).to be == ["more widgets", "widgets"]
  end

  private

  def search_for(query)
    visit "/"
    fill_in "q", with: query
    click_button "Search"
  end

  def listed_project_names
    page.find_all(".project h3").map(&:text)
  end
end
