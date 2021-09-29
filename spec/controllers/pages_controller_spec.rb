# frozen_string_literal: true

require "rails_helper"

RSpec.describe PagesController, type: :controller do
  fixtures :all

  describe "for valid page" do
    before do
      get :show, params: { id: "docs/index" }
    end

    it "responds with success" do
      expect(response).to have_http_status(:success)
    end

    it "renders expected page template" do
      expect(response).to render_template("docs/index")
    end
  end

  describe "for unknown page" do
    before do
      get :show, params: { id: "WAT" }
    end

    it "responds with 404" do
      expect(response).to have_http_status(:not_found)
    end
  end
end
