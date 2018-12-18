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

  #
  # Since we're using custom js stuff here capybaras default synchronization
  # does not help us. In order to have the fastest-possible turnaround time,
  # this will retry at a high frequency until the maximum amount of tries is reached,
  # causing an exception to be raised.
  #
  # rubocop:disable Performance/RedundantBlockCall
  def wait_for(&block)
    Retriable.retriable tries: 15, base_interval: 0.05 do
      raise "Exceeded max retries while waiting for block to pass" unless block.call
    end
  end
  # rubocop:enable Performance/RedundantBlockCall

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
