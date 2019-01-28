# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Categories Display", type: :feature, js: true do
  before do
    group = CategoryGroup.create! permalink: "group1", name: "Group"
    category = Category.create! permalink: "widgets", name: "Widgets", category_group: group
    category.projects << Factories.project("acme", score: 25, downloads: 25_000, first_release: 3.years.ago)
    category.projects << Factories.project("widget", score: 20, downloads: 50_000, first_release: 2.years.ago)
    category.projects << Factories.project("toolkit", score: 22, downloads: 10_000, first_release: 5.years.ago)
  end

  it "can display projects of a category" do
    visit "/categories/widgets"
    within ".projects" do
      expect(page).to have_text "acme"
    end
  end

  it "can apply a custom order to the list of projects" do
    visit "/categories/widgets"

    expect(listed_project_names).to be == %w[acme toolkit widget]
    expect(page).to have_selector(".hero canvas.bar-chart")

    within ".project-order-dropdown" do
      expect(page).to have_text "Order by Project Score"
    end

    %w[Downloads Stars Forks].each do |button_label|
      within ".project-order-dropdown" do
        page.find("button").hover
        click_on button_label
        expect(page).to have_text "Order by #{button_label}"
      end
      expect(listed_project_names).to be == %w[widget acme toolkit]
      expect(page).not_to have_selector(".hero canvas.bar-chart")
    end

    within ".project-order-dropdown" do
      page.find("button").hover
      click_on "First release"
    end

    within ".project-order-dropdown" do
      expect(page).to have_text "Order by First release"
    end
    expect(listed_project_names).to be == %w[toolkit acme widget]
  end

  private

  def listed_project_names
    page.find_all(".project h3").map(&:text)
  end
end
