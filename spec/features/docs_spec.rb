# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Documentation Display", :js do
  fixtures :all

  it "can display all documentation pages" do
    visit_docs
    take_snapshots! "Documentation"

    each_page do |doc|
      expect_can_visit doc.title
    end
  end

  it "has a foldable mobile navigation menu", viewport: :mobile do
    visit_docs

    # Mobile nav is collapsible
    expect(page).to have_no_css("aside .menu")
    click_button "Browse documentation topics"
    expect(page).to have_css("aside .menu")
    click_button "Browse documentation topics"
    expect(page).to have_no_css("aside .menu")

    each_page do |doc|
      click_button "Browse documentation topics"
      expect(page).to have_css("aside .menu")

      expect_can_visit doc.title
    end
  end

  it "renders the default 404 when an unknown page is accessed", js: false do
    visit "/pages/unknown"

    expect(page).to have_text("The page you were looking for doesn't exist")
  end

  private

  def expect_can_visit(doc_title)
    within "aside .menu" do
      click_link doc_title
    end

    within ".hero" do
      expect(page).to have_text(doc_title)
    end
  end

  def each_page(&)
    Docs.new.sections.map(&:last).flatten.each(&)
  end

  def visit_docs
    visit "/"

    within "footer.footer" do
      click_link "Documentation"
    end
    expect(page).to have_text "Welcome to the Ruby Toolbox documentation"
  end
end
