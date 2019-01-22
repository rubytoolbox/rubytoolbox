# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Documentation Display", type: :feature, js: true do
  it "can display all documentation pages" do
    visit_docs

    each_page do |doc|
      expect_can_visit doc.title
    end
  end

  it "has a foldable mobile navigation menu", viewport: :mobile do
    visit_docs

    # Mobile nav is collapsible
    expect(page).not_to have_selector("aside .menu")
    click_on "Browse documentation topics"
    expect(page).to have_selector("aside .menu")
    click_on "Browse documentation topics"
    expect(page).not_to have_selector("aside .menu")

    each_page do |doc|
      click_on "Browse documentation topics"
      expect(page).to have_selector("aside .menu")

      expect_can_visit doc.title
    end
  end

  private

  def expect_can_visit(doc_title)
    within "aside .menu" do
      click_on doc_title
    end

    within ".hero" do
      expect(page).to have_text(doc_title)
    end
  end

  def each_page(&block)
    Docs.new.sections.map(&:last).flatten.each(&block)
  end

  def visit_docs
    visit "/"

    within "footer.footer" do
      click_on "Documentation"
    end
    expect(page).to have_text "Welcome to the Ruby Toolbox documentation"
  end
end
