# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Documentation Display", type: :feature, js: true do
  it "can display all documentation pages" do
    Docs.new.sections.map(&:last).flatten.each do |doc|
      visit page_path(doc)
      within ".hero" do
        expect(page).to have_text(doc.title)
      end
    end
  end
end
