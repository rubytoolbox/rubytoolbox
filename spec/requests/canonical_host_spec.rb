# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Canonical host enforcement" do
  subject(:response) { Rack::MockRequest.new(app).get(url) }

  # The canonical host redirect middleware is configured in config.ru, which the
  # regular request specs bypass, so the app is built from the rackup file with
  # CANONICAL_HOST configured
  let(:app) do
    original_value = ENV.fetch("CANONICAL_HOST", nil)
    begin
      ENV["CANONICAL_HOST"] = "www.example.org"
      Rack::Builder.parse_file(Rails.root.join("config.ru").to_s)
    ensure
      ENV["CANONICAL_HOST"] = original_value
    end
  end

  context "when requested on a non-canonical host" do
    let(:url) { "https://legacy.example.org/pages/about" }

    it "redirects permanently" do
      expect(response).to have_http_status(:moved_permanently)
    end

    it "points at the same path on the canonical host" do
      expect(response.headers["location"]).to eq("https://www.example.org/pages/about")
    end
  end

  context "when the health check is requested on a non-canonical host" do
    let(:url) { "https://legacy.example.org/up" }

    it "responds successfully without redirecting" do
      expect(response).to have_http_status(:ok)
    end
  end

  context "when requested on the canonical host" do
    let(:url) { "https://www.example.org/up" }

    it "responds successfully" do
      expect(response).to have_http_status(:ok)
    end
  end
end
