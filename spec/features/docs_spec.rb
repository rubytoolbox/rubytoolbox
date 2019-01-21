# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Documentation Display", type: :feature, js: true do
  it "can display all documentation pages" do
    visit "/"

    within "header.main .navbar" do
      click_on "Docs"
    end
    expect(page).to have_text "Welcome to the Ruby Toolbox documentation"

    Docs.new.sections.map(&:last).flatten.each do |doc|
      within "aside.menu" do
        click_on doc.title
      end

      within ".hero" do
        expect(page).to have_text(doc.title)
      end
    end
  end
end
