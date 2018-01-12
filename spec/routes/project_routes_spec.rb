# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Project routes", type: :routing do
  it "routes rubygems-based projects to the project page" do
    expect(get("/projects/simplecov")).to route_to(
      controller: "projects",
      action: "show",
      id: "simplecov"
    )
  end

  it "routes rubygems-based projects with dots to the project page" do
    expect(get("/projects/simplecov.rb")).to route_to(
      controller: "projects",
      action: "show",
      id: "simplecov.rb"
    )
  end

  it "routes github-based projects to the project page" do
    expect(get("/projects/postmodern/chruby")).to route_to(
      controller: "projects",
      action: "show",
      id: "postmodern/chruby"
    )
  end
end
