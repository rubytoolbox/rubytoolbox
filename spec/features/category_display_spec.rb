# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Categories Display", type: :feature, js: true do
  def create_project(name, score:, downloads:, first_release:) # rubocop:disable Metrics/MethodLength
    rubygem = Rubygem.create!(
      name:             name,
      current_version:  "1.0",
      downloads:        downloads,
      first_release_on: first_release
    )
    github_repo = GithubRepo.create!(
      path:             "#{name}/#{name}",
      stargazers_count: downloads,
      forks_count:      downloads,
      watchers_count:   downloads
    )
    Project.create! permalink: name, score: score, rubygem: rubygem, github_repo: github_repo
  end

  before do
    group = CategoryGroup.create! permalink: "group1", name: "Group"
    category = Category.create! permalink: "widgets", name: "Widgets", category_group: group
    category.projects << create_project("acme", score: 25, downloads: 25_000, first_release: 3.years.ago)
    category.projects << create_project("widget", score: 20, downloads: 50_000, first_release: 2.years.ago)
    category.projects << create_project("toolkit", score: 22, downloads: 10_000, first_release: 5.years.ago)
  end

  it "can display projects of a category" do
    visit "/categories/widgets"
    within ".projects" do
      expect(page).to have_text "acme"
    end
  end

  it "can apply a custom order to the list of projects" do
    visit "/categories/widgets"

    expect(listed_project_names).to be == %w[acme toolkit widget]

    within ".project-order-dropdown" do
      expect(page).to have_text "Order by Project Score"
    end

    %w[Downloads Stars Forks].each do |button_label|
      within ".project-order-dropdown" do
        page.find("button").hover
        click_on button_label
        expect(page).to have_text "Order by #{button_label}"
      end
      expect(listed_project_names).to be == %w[widget acme toolkit]
    end

    within ".project-order-dropdown" do
      page.find("button").hover
      click_on "First release"
    end

    within ".project-order-dropdown" do
      expect(page).to have_text "Order by First release"
    end
    expect(listed_project_names).to be == %w[toolkit acme widget]
  end

  private

  def listed_project_names
    page.find_all(".project h3").map(&:text)
  end
end
