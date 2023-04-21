# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Styleguide Display", type: :feature, js: true do
  fixtures :all

  it "can display all pages of the styleguide" do
    visit "/pages/components"
    expect(page).to have_text "Ruby Toolbox UI Components Styleguide".upcase
    expect(page).to have_text "Components Overview"

    page_links = page.find_all(".component-list a").to_h { |a| [a["href"], a.text] }
    expect(page_links.size).to be > 0

    page_links.each do |href, text|
      visit "/pages/components"
      visit href
      expect(page).to have_text text

      take_snapshots! "Components: #{text}"
    end
  end
end
