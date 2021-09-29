# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Project Display", type: :feature do
  fixtures :all

  let(:project) do
    Factories.project "widgets"
  end

  it "can display Project README" do
    visit project_path(project)
    expect(page).not_to have_selector(".readme .content")

    project.github_repo.create_readme! html: "<strong>some content</strong>", etag: "1234"
    visit project_path(project)

    expect(page).to have_selector(".readme .content")

    within ".readme .content" do
      expect(page).to have_text("some content")
    end
  end
end
