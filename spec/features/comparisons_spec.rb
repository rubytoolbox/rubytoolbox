# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Project Comparisons", type: :feature, js: true do
  before do
    Factories.project("acme", score: 25, downloads: 25_000, first_release: 3.years.ago)
    Factories.project("widget", score: 20, downloads: 50_000, first_release: 2.years.ago)
    Factories.project("toolkit", score: 22, downloads: 10_000, first_release: 5.years.ago)
  end

  it "allows to compare arbitrary projects" do
    visit "/"
    within ".navbar" do
      click_on "Compare"
    end
    expect(page).to have_text("view any selection of projects")

    fill_in :add, with: "acme"
    click_button "Add to comparison"
    expect(page).to have_text("view any selection of projects")
    expect(listed_project_names).to be == %w[acme]
    expect(comparison_project_tags.map(&:text)).to be == %w[acme]

    fill_in :add, with: "widget"
    click_button "Add to comparison"
    expect(page).not_to have_text("view any selection of projects")
    expect(listed_project_names).to be == %w[acme widget]
    expect(comparison_project_tags.map(&:text)).to be == %w[acme widget]

    comparison_project_tags.first.find(".delete").click
    wait_for do
      expect(listed_project_names).to be == %w[widget]
    end
  end

  it "supports custom sorting and display modes" do
    visit "/compare/acme,toolkit,widget"
    expect(listed_project_names).to be == %w[acme toolkit widget]
    order_by "Downloads"
    expect(listed_project_names).to be == %w[widget acme toolkit]

    expect_display_mode "Table"
    change_display_mode "Full"
    # Custom order should remain across display mode switches
    expect(listed_project_names).to be == %w[widget acme toolkit]
    change_display_mode "Compact"
    expect(listed_project_names).to be == %w[widget acme toolkit]

    # It should keep current display settings on add
    fill_in :add, with: "irrelevant"
    click_button "Add to comparison"
    expect_display_mode "Compact"
    expect(listed_project_names).to be == %w[widget acme toolkit]

    # It should keep current display settings on remove
    comparison_project_tags.first.find(".delete").click
    wait_for do
      expect(listed_project_names).to be == %w[widget toolkit]
    end
    expect_display_mode "Compact"
  end

  it "has working autocompletion for project addition form" do
    visit "/compare"

    add_using_autocomplete "widget"
    wait_for do
      expect(listed_project_names).to be == %w[widget]
    end

    add_using_autocomplete "toolkit"
    wait_for do
      expect(listed_project_names).to be == %w[toolkit widget]
    end
  end

  private

  def add_using_autocomplete(name)
    page.find("input.autocomplete-comparison").send_keys name[0..2]
    expect(page).to have_selector(".autocomplete-suggestions")
    page.find("input.autocomplete-comparison").send_keys :down, :enter
  end

  def comparison_project_tags
    page.find_all(".hero .tags .tag")
  end
end
