# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComparisonsController, type: :controller do
  before do
    Factories.project "a", score: 30, downloads: 5000
    Factories.project "b", score: 25, downloads: 40_000
    Factories.project "c", score: 20, downloads: 3000
  end

  describe "GET show" do
    shared_examples_for "a successful request" do
      it "responds with success" do
        do_request
        expect(response).to have_http_status(:success)
      end

      it "renders show template" do
        do_request
        expect(response).to render_template(:show)
      end
    end

    describe "without params" do
      let(:do_request) { get :show }

      it_behaves_like "a successful request"
    end

    describe "with valid ids" do
      it "redirects to sorted ids when querying invalid order" do
        get :show, params: { id: "b,c,a" }
        expect(response).to redirect_to("/compare/a,b,c")
      end

      it "redirects to distinct ids when querying duplicates" do
        get :show, params: { id: "b,c,a,c,b" }
        expect(response).to redirect_to("/compare/a,b,c")
      end

      it "redirects to valid ids when querying with invalid projects" do
        get :show, params: { id: "b,c,a,404" }
        expect(response).to redirect_to("/compare/a,b,c")
      end

      describe "when requesting in correct order" do
        let(:do_request) { get :show, params: { id: "a,b,c" } }

        it_behaves_like "a successful request"
      end
    end

    #
    # The add param is used to append projects to the comparison
    #
    describe "adding a project to comparison via param" do
      describe "when comparison list is empty" do
        it "redirects to comparison page with given project" do
          get :show, params: { add: "a" }
          expect(response).to redirect_to("/compare/a")
        end

        it "redirects to plain compare path when added project is invalid" do
          get :show, params: { add: "404" }
          expect(response).to redirect_to("/compare")
        end
      end

      describe "when comparison list already has projects" do
        it "redirects to comparison page with given project" do
          get :show, params: { add: "a", id: "c,b" }
          expect(response).to redirect_to("/compare/a,b,c")
        end

        it "redirects to compare path with valid projects when added project is invalid" do
          get :show, params: { add: "404", id: "c,b" }
          expect(response).to redirect_to("/compare/b,c")
        end
      end
    end
  end
end
