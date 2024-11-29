# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Project Comparisons", :js do
  fixtures :all

  before do
    Factories.project("acme", score: 25, downloads: 25_000, first_release: Date.new(2018, 5, 6))
    Factories.project("widget", score: 20, downloads: 50_000, first_release: Date.new(2019, 5, 6))
    Factories.project("toolkit", score: 22, downloads: 10_000, first_release: Date.new(2016, 5, 6))
  end

  it "allows to compare arbitrary projects" do
    visit "/"
    within ".navbar" do
      click_link "Compare"
    end
    expect(page).to have_text("view any selection of projects")

    fill_in :add, with: "acme"
    click_button "Add to comparison"
    expect(page).to have_text("view any selection of projects")
    expect(listed_project_names).to eq %w[acme]
    expect(comparison_project_tags.map(&:text)).to eq %w[acme]

    fill_in :add, with: "widget"
    click_button "Add to comparison"
    expect(page).to have_no_text("view any selection of projects")
    expect(listed_project_names).to eq %w[acme widget]
    expect(comparison_project_tags.map(&:text)).to eq %w[acme widget]

    take_snapshots! "Compare Projects: Default View"

    comparison_project_tags.first.find(".delete").click
    wait_for do
      listed_project_names == %w[widget]
    end
  end

  it "supports custom sorting and display modes" do
    visit "/compare/acme,toolkit,widget"
    expect(listed_project_names).to eq %w[acme toolkit widget]
    order_by "Downloads"
    expect(listed_project_names).to eq %w[widget acme toolkit]

    expect_display_mode "Table"
    change_display_mode "Full"
    # Custom order should remain across display mode switches
    expect(listed_project_names).to eq %w[widget acme toolkit]
    change_display_mode "Compact"
    expect(listed_project_names).to eq %w[widget acme toolkit]

    # It should keep current display settings on add
    fill_in :add, with: "irrelevant"
    click_button "Add to comparison"
    expect_display_mode "Compact"
    expect(listed_project_names).to eq %w[widget acme toolkit]

    # It should keep current display settings on remove
    comparison_project_tags.first.find(".delete").click
    wait_for do
      listed_project_names == %w[widget toolkit]
    end
    expect_display_mode "Compact"
  end

  it "has working autocompletion for project addition form" do # rubocop:disable RSpec/NoExpectationExample wait_for would fail eventually
    visit "/compare"

    add_using_autocomplete "widget"
    wait_for do
      listed_project_names == %w[widget]
    end

    add_using_autocomplete "toolkit"
    wait_for do
      listed_project_names == %w[toolkit widget]
    end

    # Our autocomplete library interferes with the enter key on the input field -
    # it should be possible to just type a name and hit enter without interacting
    # with the autocompletion in any way.
    autocomplete_input.send_keys "acme", :enter
    wait_for do
      listed_project_names == %w[acme toolkit widget]
    end
  end

  private

  def add_using_autocomplete(name)
    autocomplete_input.send_keys name[0..2]
    expect(page).to have_css(".autocomplete__menu--overlay")
    autocomplete_input.send_keys :down, :enter
  end

  def autocomplete_input
    page.find "input#comparison-autocomplete"
  end

  def comparison_project_tags
    page.find_all(".hero .tags .tag")
  end
end
