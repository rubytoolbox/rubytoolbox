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
      Factories.project "rake"
      Factories.project "rspec", score: 26
    end

    it "responds with expected projects" do
      do_request

      expect(Oj.load(response.body)).to match(
        "projects" => [
          ProjectBlueprint.render_as_json(Project.find("rspec")),
          ProjectBlueprint.render_as_json(Project.find("rake")),
        ]
      )
    end

    it "responds with success" do
      do_request
      expect(response).to have_http_status(:success)
    end
  end
end
