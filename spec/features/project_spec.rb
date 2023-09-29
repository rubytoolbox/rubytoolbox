# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Project Display" do
  fixtures :all

  it "can display Project README" do
    project = Factories.project "widgets"

    visit project_path(project)
    expect(page).not_to have_selector(".readme .content")

    project.github_repo.create_readme! html: "<strong>some content</strong>", etag: "1234"
    visit project_path(project)

    expect(page).to have_selector(".readme .content")

    within ".readme .content" do
      expect(page).to have_text("some content")
    end
  end

  it "can display a project's reverse dependencies", :js do
    project = Project.find("bundler")

    visit project_path(project)

    within '.metric[data-metric-name="rubygem_reverse_dependencies_count"]' do
      page.find("a.button").click
    end

    within ".hero" do
      expect(page).to have_text "Reverse Dependencies for bundler"
    end

    expect_display_mode "Compact"
    take_snapshots! "Reverse Dependencies: Compact View"

    shown_dependencies = page.all(".project.box h3").map(&:text)

    project.reverse_dependencies.then do |expected|
      expect(shown_dependencies).to eq expected.map(&:name)
    end

    change_display_mode "Full"
    change_display_mode "Table"
  end
end
