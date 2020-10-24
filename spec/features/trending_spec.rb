# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Trending Projects", type: :feature, js: true do
  before do
    Factories.project "foobar"
    Factories.project "widget"
    Factories.project "other"

    Factories.rubygem_trend "foobar", date: Time.current, position: 2, with_stats: true
    Factories.rubygem_trend "widget", date: Time.current, position: 1, with_stats: true
    Factories.rubygem_trend "other", date: 1.week.ago, position: 1, with_stats: true
  end

  it "allows users to look at trending projects" do
    visit "/"
    within ".trending-projects" do
      expect(page).to have_selector(".category-card", count: 2)
      expect(page).to have_text("foobar")
      expect(page).to have_text("widget")
    end

    within(".footer") { click_on "Trends" }

    take_snapshots! "Trending Projects: Default View"

    within ".hero" do
      expect(page).to have_text("Trending Projects for #{I18n.l(Time.current.to_date, format: :long)}")
    end
    expect(page).to have_selector(".category-card", count: 2)
    expect(visible_project_names).to be == %w[widget foobar]

    within '.top-navigation' do
      page.find(".button.previous_week").click
    end

    expect(page).to have_selector(".category-card", count: 1)
    expect(visible_project_names).to be == %w[other]

    within '.top-navigation' do
      click_on "Go to latest"
    end

    expect(page).to have_selector(".category-card", count: 2)
    expect(visible_project_names).to be == %w[widget foobar]
  end

  private

  def visible_project_names
    page.find_all(".card-header-title").map(&:text)
  end
end
