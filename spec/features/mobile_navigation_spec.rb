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

    navbar_selector = "header.main .navbar"

    expect(page).to have_selector(navbar_selector, visible: true)
    expect(element_top_position(navbar_selector)).to be_zero

    scroll_by 1000
    sleep 0.3 # We have to wait for the transition
    expect(element_top_position(navbar_selector)).to be < 0.0

    scroll_by(-100)
    sleep 0.3 # We have to wait for the transition

    expect(element_top_position(navbar_selector)).to be_zero
  end

  private

  def scroll_by(y) # rubocop:disable Naming/UncommunicativeMethodParamName
    # Perform the actual scroll
    page.execute_script "window.scrollBy(0, #{y})"
    # Dispatch a scroll event - this does not seem to happen in headless chrome using scrollBy
    page.execute_script "document.dispatchEvent(new Event('scroll'))"
  end

  def element_top_position(selector)
    page.evaluate_script("document.querySelector(#{selector.inspect}).getBoundingClientRect().top")
  end
end
