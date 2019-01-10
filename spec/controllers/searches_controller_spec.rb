# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchesController, type: :controller do
  describe "GET #show" do
    def do_request(query: nil, order: nil)
      get :show, params: { q: query, order: order }
    end

    it "returns http success" do
      do_request
      expect(response).to be_successful
    end

    it "assigns nothing to search when there is no query" do
      do_request query: " "
      expect(assigns(:search)).to be_nil
    end

    it "assigns a Search instance to search when there is a query" do
      do_request query: "foo"
      expect(assigns(:search)).to be_a Search
    end

    it "assigns paginated projects scope when there is a query" do
      do_request query: "foo"
      expect(assigns(:projects)).to be_a(ActiveRecord::Relation)
        .and respond_to(:current_page)
        .and respond_to(:total_pages)
    end

    it "passes query and a project order instance to Search.new" do
      order = Project::Order.new(order: "rubygem_downloads")
      allow(Project::Order).to receive(:new)
        .with(order: "rubygem_downloads", directions: Project::Order::SEARCH_DIRECTIONS)
        .and_return(order)
      expect(Search).to receive(:new).with("hello world", order: order).and_call_original
      do_request query: "hello world", order: "rubygem_downloads"
    end
  end
end
