# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Mobile Navigation", type: :feature, js: true do
  it "has a toggle-able hamburger navigation on mobile" do
    Capybara.current_session.current_window.resize_to 450, 900

    visit "/"

    within "header .navbar" do
      expect(page).not_to have_css(".navbar-menu")

      page.find("a.navbar-burger").click

      expect(page).to have_css(".navbar-menu")
      within ".navbar-menu" do
        expect(page).to have_text("Home")
        expect(page).to have_text("News")

        fill_in :q, with: "My Search"
        click_button "Search"
        expect(page.title).to be == "Search results for 'My Search' - The Ruby Toolbox"
      end
    end
  end

  it "has the sticky main nav re-appear when scrolling back up" do
    Capybara.current_session.current_window.resize_to 450, 900
    visit "/"

    expect(page).to have_selector("header.main .navbar", visible: true)

    page.execute_script "window.scrollBy(0,10000)"

    expect(page).to have_selector("header.main .navbar", visible: false)

    page.execute_script "window.scrollBy(0,-1)"

    expect(page).to have_selector("header.main .navbar", visible: true)
  end
end
