# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchesController, type: :controller do
  describe "GET #show" do
    def do_request(query: "foobar", order: nil, show_forks: nil, display: nil)
      get :show, params: { q: query, order: order, show_forks: show_forks, display: display }
    end

    it_behaves_like "pickable project display listing", "compact"

    it "returns http success" do
      Factories.project "foobar"
      do_request query: "foobar"
      expect(response).to have_http_status(:success)
    end

    it "renders show template" do
      Factories.project "foobar"
      do_request query: "foobar"
      expect(response).to render_template(:show)
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

    it "passes query, a project order instance and show_forks status to Search.new" do
      search = Search.new("hello world")
      order = Project::Order.new(order: "rubygem_downloads")
      allow(Project::Order).to receive(:new)
        .with(order: "rubygem_downloads", directions: Project::Order::SEARCH_DIRECTIONS)
        .and_return(order)
      expect(Search).to receive(:new).with("hello world", order: order, show_forks: false)
                                     .and_return(search)
      do_request query: "hello world", order: "rubygem_downloads"
    end

    it "passes show_forks true to search when set in params" do
      expect(Search).to receive(:new)
        .with(
          kind_of(String),
          order:      kind_of(Project::Order),
          show_forks: true
        )
        .and_return(Search.new("hello world"))
      do_request query: "hello world", order: "rubygem_downloads", show_forks: true
    end

    it "redirects to results including forks when project search has no results" do
      get :show, params: { q: "my query" }
      expect(response).to redirect_to(search_path(q: "my query", order: "rank", show_forks: true))
    end

    it "does not redirect when project search has no results but explicit show forks is given" do
      get :show, params: { q: "my query", show_forks: true }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET by_name" do
    it "requests list of matching project names to Project.suggest" do
      expect(Project).to receive(:suggest).with("foobar").and_return([])
      get :by_name, params: { q: "foobar" }
    end

    it "returns list of matching project names as json" do
      allow(Project).to receive(:suggest).with("foobar").and_return(%w[a b c])
      get :by_name, params: { q: "foobar" }
      expect(Oj.load(response.body)).to be == %w[a b c]
    end
  end
end
