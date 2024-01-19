# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Search", :js do
  fixtures :all

  before do
    group = CategoryGroup.create! permalink: "group1", name: "Group"
    Category.create! permalink: "widgets", name: "Widgets", category_group: group

    Factories.project "widgets", score: 50, downloads: 125_000, first_release: Date.new(2018, 3, 1)
    Factories.project "more widgets",
                      score:         50,
                      description:   "widgets widgets",
                      downloads:     50_000,
                      first_release: Date.new(2016, 3, 1)
    Factories.project "other", score: 22, downloads: 10_000, first_release: Date.new(2016, 3, 1)
  end

  let(:halt_form_submission_js) do
    <<~JS
      document.querySelectorAll(".search-form").forEach(function(form) {
        form.addEventListener("submit", function(e) { e.preventDefault(); })
      });
    JS
  end

  it "allows users to search for projects and categories" do
    search_for "widget"

    expect(listed_project_names).to eq ["more widgets", "widgets"]

    take_snapshots! "Search: Default View"

    expect_display_mode "Compact"
    change_display_mode "Table"
    change_display_mode "Full"

    within ".category-card" do
      expect(page).to have_text "Widgets"
      expect(page).to have_no_text "No matching categories were found"
    end

    search_for "bicycle"
    expect(page).to have_text "No matching categories were found"
    expect(page).to have_text "No matching projects were found"

    # Landing page search from within top hero
    search_for "widget", container: ".landing-hero"
    expect(listed_project_names).to eq ["more widgets", "widgets"]
  end

  it "can apply a custom project order" do
    search_for "widget"

    expect(listed_project_names).to eq ["more widgets", "widgets"]

    expect(page).to have_css(".category-card", count: 1)

    %w[Downloads Stars Forks].each do |button_label|
      order_by button_label
      expect(listed_project_names).to eq ["widgets", "more widgets"]

      # When using a custom order, matching categories are not shown
      # since they are not affected by the order anyway, and if a user
      # picks a custom project order it's reasonably safe to assume
      # they are looking for projects, not categories
      expect(page).to have_no_css(".category-card")
      expect(page).to have_text "Category results are hidden"
    end

    order_by "First release"
    expect(listed_project_names).to eq ["more widgets", "widgets"]

    # Ensure the button is correctly put into loading state on click
    halt_js = <<~JS
      document.querySelectorAll(".project-order-dropdown a").forEach(function(button) {
        button.addEventListener("click", function(e) { e.preventDefault(); })
      });
    JS
    page.evaluate_script halt_js
    order_by "Downloads", expect_navigation: false
    expect(page).to have_css(".project-order-dropdown button.is-loading")
  end

  it "paginates large project collections" do
    7.times do |i|
      Factories.project "widgets #{i + 1}", score: 40 - i
    end

    search_for "widgets"

    expect(listed_project_names).to eq ["more widgets", "widgets", "widgets 1"]
    within(".search-results") { expect(page).to have_text "Categories" }

    within ".pagination", match: :first do
      click_link "Next page"
    end

    wait_for { listed_project_names.include? "widgets 2" }
    expect(listed_project_names).to eq((2..4).map { |i| "widgets #{i}" })
    # Only project results are paginated, hence we hide the categories section entirely
    # when browsing project results
    within(".search-results") { expect(page).to have_no_text "Categories" }

    within ".pagination", match: :first do
      click_link "3"
    end

    wait_for { listed_project_names.include? "widgets 5" }
    expect(listed_project_names).to eq((5..7).map { |i| "widgets #{i}" })
  end

  it "hides bugfix forks from results by default, but allows to toggle their display" do
    Project.find("more widgets").update! is_bugfix_fork: true

    search_for "widget"

    expect(listed_project_names).to eq ["widgets"]
    within ".project-search-nav" do
      click_link "Bugfix forks are hidden"
    end

    wait_for { listed_project_names.include? "more widgets" }
    expect(listed_project_names).to eq ["more widgets", "widgets"]
    expect(page).to have_text "Bugfix forks are shown"

    # Re-ordering should retain show_forks status
    order_by "Downloads"
    expect(listed_project_names).to eq ["widgets", "more widgets"]
    expect(page).to have_text "Bugfix forks are shown"

    within ".project-search-nav" do
      click_link "Bugfix forks are shown"
    end

    wait_for { listed_project_names.exclude?("more widgets") }
    expect(listed_project_names).to eq ["widgets"]

    # When there are no results from projects search without
    # forks we redirect to the page with included forks automatically
    search_for "more widgets"
    expect(listed_project_names).to eq ["more widgets"]

    # Ensure the button is correctly put into loading state on click
    halt_js = <<~JS
      document.querySelectorAll("a.bugfix-forks-toggle").forEach(function(button) {
        button.addEventListener("click", function(e) { e.preventDefault(); })
      });
    JS
    page.evaluate_script halt_js
    click_link "Bugfix forks are shown"
    expect(page).to have_css("a.bugfix-forks-toggle.is-loading")

    # Ensure help page is accessible
    page.find(".project-search-nav a.bugfix-forks-help").click
    within ".hero" do
      expect(page).to have_text("Bugfix Forks")
    end
  end

  it "automatically focuses the search input when accessed without query" do
    search_for ""
    expect(active_element).to(satisfy { |e| e.tag_name == "input" && e["name"] == "q" })

    search_for "foo"
    expect(active_element.tag_name).to eq "body"
  end

  it "puts search submit buttons into loading state" do
    search_for "foo", halt: true
    expect(page).to have_css(".search-form .button.is-loading", count: 2)
  end

  it "keeps the chosen search display mode across searches" do
    search_for "widget"
    change_display_mode "Table"
    search_for "widget", visit_home_first: false
    expect_display_mode "Table"

    visit "/categories/widgets"
    change_display_mode "Table"
    search_for "widget", visit_home_first: false
    expect_display_mode "Compact"
  end

  private

  #
  # To test onSubmit loading state change we need to prevent the form from actually
  # submitting itself
  #

  def search_for(query, container: ".navbar", halt: false, visit_home_first: true)
    visit "/" if visit_home_first

    page.evaluate_script halt_form_submission_js if halt

    within container do
      fill_in "q", with: query
      click_button "Search"
    end
  end
end
