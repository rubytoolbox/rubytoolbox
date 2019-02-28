# frozen_string_literal: true

require "rails_helper"

RSpec.describe TrendsController, type: :controller do
  render_views

  describe "GET index" do
    it "redirects to show for maximum available stat date" do
      allow(RubygemDownloadStat::Navigation).to receive(:latest_date).and_return(Date.new(2019, 1, 2))
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
    before do
      Factories.rubygem "foo"
      RubygemDownloadStat.create! rubygem_name:    "foo",
                                  date:            "2019-02-24",
                                  total_downloads: 5000
    end

    def do_request
      get :show, params: { id: "2019-02-24" }
    end

    it "renders show template" do
      expect(do_request).to render_template :show
    end

    it "assigns a navigation instance" do
      navigation = RubygemDownloadStat::Navigation.new(Date.new(2019, 2, 24))
      allow(RubygemDownloadStat::Navigation).to receive(:find)
        .with("2019-02-24")
        .and_return(navigation)

      do_request
      expect(assigns(:navigation)).to be navigation
    end

    it "redirects to next available date on invalid date" do
      get :show, params: { id: "2019-01-28" }
      expect(response).to redirect_to(action: :show, id: "2019-02-24")
    end
  end
end
