# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Mobile Navigation", :js, viewport: :mobile do
  fixtures :all

  it "has a toggle-able hamburger navigation on mobile" do
    visit "/"

    within "header .navbar" do
      expect(page).to have_no_css(".navbar-menu")

      page.find("a.navbar-burger").click

      expect(page).to have_css(".navbar-menu")
      within ".navbar-menu" do
        expect(page).to have_text("Home")
        expect(page).to have_text("News")

        fill_in :q, with: "My Search"
        click_button "Search"
        expect(page.title).to eq "Search results for 'My Search' - The Ruby Toolbox"
      end
    end
  end

  it "has the sticky main nav re-appear when scrolling back up" do
    visit "/"

    navbar_selector = "header.main .navbar"

    expect(page).to have_selector(navbar_selector)

    wait_for do
      scroll_by 260
      element_top_position(navbar_selector) < 0
    end

    expect(element_top_position(navbar_selector)).to be < 0.0

    wait_for do
      scroll_by(-10)
      element_top_position(navbar_selector).zero?
    end
    expect(element_top_position(navbar_selector)).to be_zero
  end

  private

  def scroll_by(y) # rubocop:disable Naming/MethodParameterName it's fine rubocop...
    # Perform the actual scroll
    page.execute_script "window.scrollBy(0, #{y})"
    # Dispatch a scroll event - this does not seem to happen in headless chrome using scrollBy
    page.execute_script "document.dispatchEvent(new Event('scroll'))"
  end

  def element_top_position(selector)
    page.evaluate_script("document.querySelector(#{selector.inspect}).getBoundingClientRect().top")
  end
end
