# frozen_string_literal: true

require "rails_helper"

RSpec.describe CanonicalUrlHelper do
  describe "#canonical_url" do
    def canonical_for(path, **params)
      controller.request.path_info = path
      controller.request.query_string = params.to_query
      helper.canonical_url
    end

    it "is the absolute url of the current path" do
      expect(canonical_for("/projects/rails")).to eq "http://test.host/projects/rails"
    end

    it "drops params that do not change the page content" do
      expect(canonical_for("/categories/web", order: "downloads", display: "table", show_forks: "true"))
        .to eq "http://test.host/categories/web"
    end

    it "keeps the search query" do
      expect(canonical_for("/search", q: "rails", order: "stars")).to eq "http://test.host/search?q=rails"
    end

    it "keeps the page for later pages" do
      expect(canonical_for("/categories/web", page: "2")).to eq "http://test.host/categories/web?page=2"
    end

    it "drops the page param for the first page" do
      expect(canonical_for("/categories/web", page: "1")).to eq "http://test.host/categories/web"
    end

    it "ignores blank params" do
      expect(canonical_for("/search", q: "", page: "")).to eq "http://test.host/search"
    end
  end
end
