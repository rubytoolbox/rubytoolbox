# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Health check" do
  it "responds with success" do
    get "/up"
    expect(response).to have_http_status(:success)
  end
end
