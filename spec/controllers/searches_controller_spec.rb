# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchesController do
  fixtures :all

  # Stubs the getter for a single ENV var without touching the real
  # environment; other ENV lookups still call through.
  def stub_env(key, value)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with(key).and_return(value)
  end

  describe ".search_disabled?" do
    it "is false when DISABLE_SEARCH is not set" do
      stub_env "DISABLE_SEARCH", nil
      expect(described_class).not_to be_search_disabled
    end

    it "is true when DISABLE_SEARCH is set" do
      stub_env "DISABLE_SEARCH", "1"
      expect(described_class).to be_search_disabled
    end
  end

  describe ".statement_timeout_ms" do
    it "defaults to DEFAULT_STATEMENT_TIMEOUT_MS when the env var is not set" do
      stub_env "SEARCH_STATEMENT_TIMEOUT_MS", nil
      expect(described_class.statement_timeout_ms).to eq described_class::DEFAULT_STATEMENT_TIMEOUT_MS
    end

    it "uses SEARCH_STATEMENT_TIMEOUT_MS when set to a positive integer" do
      stub_env "SEARCH_STATEMENT_TIMEOUT_MS", "1234"
      expect(described_class.statement_timeout_ms).to eq 1234
    end

    it "falls back to the default when the env var is not a positive integer" do
      stub_env "SEARCH_STATEMENT_TIMEOUT_MS", "nope"
      expect(described_class.statement_timeout_ms).to eq described_class::DEFAULT_STATEMENT_TIMEOUT_MS
    end
  end

  describe "GET #show" do
    def do_request(query: "foobar", order: nil, show_forks: nil, display: nil)
      get :show, params: { q: query, order:, show_forks:, display: }
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
      expect(Search).to receive(:new).with("hello world", order:, show_forks: false)
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

    describe "when search is disabled" do
      before { allow(described_class).to receive(:search_disabled?).and_return(true) }

      it "does not perform a search" do
        expect(Search).not_to receive(:new)
        do_request query: "foobar"
      end

      it "renders the unavailable template with a service unavailable status" do
        do_request query: "foobar"
        expect(response).to have_http_status(:service_unavailable).and render_template(:unavailable)
      end
    end

    it "renders the unavailable template when a search query times out" do
      allow(Search).to receive(:new).and_raise(ActiveRecord::QueryCanceled)
      do_request query: "foobar"
      expect(response).to have_http_status(:service_unavailable).and render_template(:unavailable)
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
      expect(Oj.load(response.body)).to eq %w[a b c]
    end
  end
end
