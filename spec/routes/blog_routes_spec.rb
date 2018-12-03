# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Blog routes", type: :routing do
  it "routes valid post slugs correctly" do
    expect(get("/blog/2018-12-01/foo-bar")).to route_to(
      controller: "blog",
      action:     "show",
      id:         "2018-12-01/foo-bar"
    )
  end
end
