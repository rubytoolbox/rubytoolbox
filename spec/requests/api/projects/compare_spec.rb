# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Project Comparison API", type: :request do
  def do_request
    get "/api/projects/compare/#{query}"
  end

  shared_examples_for "an empty response" do
    it "is successful" do
      do_request
      expect(response).to have_http_status(:success)
    end

    it "is empty inside" do
      do_request
      expect(Oj.load(response.body)).to be == {
        "projects" => [],
      }
    end
  end

  describe "when none of the projects are known" do
    let(:query) { "foo,bar,baz" }

    it_behaves_like "an empty response"
  end

  describe "when no projects are given" do
    let(:query) { "" }

    it_behaves_like "an empty response"
  end

  describe "when projects are known" do
    let(:query) { "rake,rspec" }

    before do
      Factories.project("rake").tap { |rake| rake.update! categories: [Factories.category("Foo")] }
      Factories.project "rspec"
    end

    it "responds with expected projects" do
      do_request

      expect(Oj.load(response.body)).to match(
        "projects" => [
          ProjectBlueprint.render_as_json(Project.find("rake"), root_url: "http://www.example.com"),
          ProjectBlueprint.render_as_json(Project.find("rspec"), root_url: "http://www.example.com"),
        ]
      )
    end

    it "responds with success" do
      do_request
      expect(response).to have_http_status(:success)
    end
  end

  describe "when more projects than limit are requested" do
    let(:limit) { Api::Projects::ComparisonsController::LIMIT }
    let(:query) { ("aa".."zz").first(limit + 1).join(",") }

    it "responds with a 400 error" do
      do_request
      expect(response.status).to be == 400
    end

    it "responds with an informative error message" do
      do_request
      body = Oj.load(response.body).deep_symbolize_keys

      expect(body).to be == {
        error_code: "too_many_projects_requested",
        message:    "Please request no more than #{limit} projects per API call",
      }
    end
  end

  describe "when being requested cross-origin" do
    def do_request
      get "/api/projects/compare/foo", headers: { "HTTP_ORIGIN" => "foo.com" }
    end

    it "responds with an appropriate CORS origin header" do
      do_request

      expect(response.headers).to have_key("Access-Control-Allow-Origin")
    end

    it "responds with an appropriate CORS methods header" do
      do_request

      expect(response.headers).to have_key("Access-Control-Allow-Methods")
    end
  end
end
