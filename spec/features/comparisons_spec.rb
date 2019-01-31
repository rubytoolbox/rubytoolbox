# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Project Comparisons", type: :feature, js: true do
  before do
    Factories.project("acme", score: 25, downloads: 25_000, first_release: 3.years.ago)
    Factories.project("widget", score: 20, downloads: 50_000, first_release: 2.years.ago)
    Factories.project("toolkit", score: 22, downloads: 10_000, first_release: 5.years.ago)
  end

  it "allows to compare arbitrary projects" do
    visit "/"
    within ".navbar" do
      click_on "Compare"
    end
    expect(page).to have_selector("article.blog-post")

    fill_in :add, with: "acme"
    click_button "Add to comparison"
    expect(page).not_to have_selector("article.blog-post")
    expect(listed_project_names).to be == %w[acme]
    expect(comparison_project_tags.map(&:text)).to be == %w[acme]

    fill_in :add, with: "widget"
    click_button "Add to comparison"
    expect(listed_project_names).to be == %w[acme widget]
    expect(comparison_project_tags.map(&:text)).to be == %w[acme widget]

    comparison_project_tags.first.find(".delete").click
    wait_for do
      expect(listed_project_names).to be == %w[widget]
    end
  end

  private

  def listed_project_names
    page.find_all(".project-comparison tbody th").map(&:text)
  end

  def comparison_project_tags
    page.find_all(".hero .tags .tag")
  end
end
