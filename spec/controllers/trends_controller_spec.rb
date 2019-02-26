# frozen_string_literal: true

require "rails_helper"

RSpec.describe TrendsController, type: :controller do
  render_views

  describe "GET index" do
    it "redirects to show for maximum available stat date" do
      allow(RubygemDownloadStat).to receive(:maximum).with(:date).and_return(Date.new(2019, 1, 2))
      get :index
      expect(response).to redirect_to(action: :show, id: "2019-01-02")
    end

    it "renders a text message when no data is in the database" do
      allow(RubygemDownloadStat).to receive(:maximum).with(:date)
      get :index
      expect(response.body).to be == "No stats data is available, please seed the database"
    end
  end

  describe "GET show" do
    def do_request
      get :show, params: { id: "2019-02-24" }
    end

    it "renders show template" do
      expect(do_request).to render_template :show
    end
  end
end
