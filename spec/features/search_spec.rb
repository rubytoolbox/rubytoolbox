# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Search", type: :feature, js: true do
  before do
    group = CategoryGroup.create! permalink: "group1", name: "Group"
    Category.create! permalink: "widgets", name: "Widgets", category_group: group

    Factories.project "widgets", score: 50, downloads: 125_000, first_release: 3.years.ago
    Factories.project "more widgets",
                      score:         50,
                      description:   "widgets widgets",
                      downloads:     50_000,
                      first_release: 5.years.ago
    Factories.project "other", score: 22, downloads: 10_000, first_release: 5.years.ago
  end

  it "allows users to search for projects and categories" do
    search_for "widget"

    expect(listed_project_names).to be == ["more widgets", "widgets"]

    within ".category-card" do
      expect(page).to have_text "Widgets"
      expect(page).not_to have_text "No matching categories were found"
    end

    search_for "bicycle"
    expect(page).to have_text "No matching categories were found"
    expect(page).to have_text "No matching projects were found"

    # Landing page search from within top hero
    search_for "widget", container: ".landing-hero"
    expect(listed_project_names).to be == ["more widgets", "widgets"]
  end

  it "can apply a custom project order" do
    search_for "widget"

    expect(listed_project_names).to be == ["more widgets", "widgets"]

    expect(page).to have_selector(".category-card", count: 1)

    %w[Downloads Stars Forks].each do |button_label|
      within ".project-order-dropdown" do
        page.find("button").hover
        click_on button_label
        expect(page).to have_text "Order by #{button_label}"
      end
      expect(listed_project_names).to be == ["widgets", "more widgets"]

      # When using a custom order, matching categories are not shown
      # since they are not affected by the order anyway, and if a user
      # picks a custom project order it's reasonably safe to assume
      # they are looking for projects, not categories
      expect(page).not_to have_selector(".category-card")
      expect(page).to have_text "Category results are hidden"
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

  it "paginates large project collections" do
    7.times do |i|
      Factories.project "widgets #{i + 1}", score: 40 - i
    end

    search_for "widgets"

    expect(listed_project_names).to be == ["more widgets", "widgets", "widgets 1"]
    within(".search-results") { expect(page).to have_text "Categories" }

    within ".pagination", match: :first do
      click_on "Next page"
    end

    wait_for { listed_project_names.include? "widgets 2" }
    expect(listed_project_names).to be == (2..4).map { |i| "widgets #{i}" }
    # Only project results are paginated, hence we hide the categories section entirely
    # when browsing project results
    within(".search-results") { expect(page).not_to have_text "Categories" }

    within ".pagination", match: :first do
      click_on "3"
    end

    wait_for { listed_project_names.include? "widgets 5" }
    expect(listed_project_names).to be == (5..7).map { |i| "widgets #{i}" }
  end

  it "automatically focuses the search input when accessed without query" do
    search_for ""
    expect(active_element).to(satisfy { |e| e.tag_name == "input" && e["name"] == "q" })

    search_for "foo"
    expect(active_element.tag_name).to be == "body"
  end

  it "puts search submit buttons into loading state" do
    search_for "foo", halt: true
    expect(page).to have_selector(".search-form .button.is-loading", count: 2)
  end

  private

  #
  # To test onSubmit loading state change we need to prevent the form from actually
  # submitting itself
  #
  HALT_FORM_SUBMISSION_JS = <<~JS
    document.querySelectorAll(".search-form").forEach(function(form) {
      form.addEventListener("submit", function(e) { e.preventDefault(); })
    });
  JS

  def search_for(query, container: ".navbar", halt: false)
    visit "/"

    page.evaluate_script HALT_FORM_SUBMISSION_JS if halt

    within container do
      fill_in "q", with: query
      click_button "Search"
    end
  end
end
