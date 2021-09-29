# frozen_string_literal: true

require "rails_helper"

RSpec.describe MeiliSearch, type: :service do
  fixtures :all

  let(:search) do
    described_class.new(url: "https://example.com")
  end

  describe ".client" do
    around do |example|
      original_value = ENV["MEILI_SEARCH_URL"]
      ENV["MEILI_SEARCH_URL"] = configured_url
      example.run
    ensure
      ENV["MEILI_SEARCH_URL"] = original_value
    end

    describe "when MEILI_SEARCH_URL is not configured" do
      let(:configured_url) { nil }

      it "returns nil" do
        expect(described_class.client).to be nil
      end
    end

    describe "when MEILI_SEARCH_URL is configured" do
      let(:configured_url) { "https://search.ruby-toolbox.com" }

      it "returns client instance configured with the URL" do
        the_instance = instance_double described_class

        allow(described_class).to receive(:new)
          .with(url: configured_url)
          .and_return(the_instance)

        expect(described_class.client).to be the_instance
      end
    end
  end

  describe "initialize" do
    it "configures HTTP client for basic_auth when configured" do
      search = described_class.new(url: "https://foo:bar@example.com")

      authorization = search.http.default_options.headers["Authorization"]
      expect(authorization).to be == "Basic Zm9vOmJhcg=="
    end

    it "skips basic_auth when not configured" do
      search = described_class.new(url: "https://example.com")

      expect(search.http.default_options.headers.keys).to be_empty
    end

    it "configures persistent connection for host and scheme" do
      search = described_class.new(url: "https://example.com")

      expect(search.http.default_options.persistent).to be == "https://example.com"
    end
  end

  describe "index settings" do
    before do
      stub_request(:get, "https://example.com/indexes/my_index/settings")
        .to_return(status: 200, body: {
          rankingRules:         %w[hello world],
          searchableAttributes: %w[foo bar],
          displayedAttributes:  %w[one two],
        }.to_json)
    end

    it "returns ranking rules as reported by server" do
      expect(search.ranking_rules("my_index")).to be == %w[hello world]
    end

    it "returns searchable attributes as reported by server" do
      expect(search.searchable_attributes("my_index")).to be == %w[foo bar]
    end

    it "returns displayed attributes as reported by server" do
      expect(search.displayed_attributes("my_index")).to be == %w[one two]
    end
  end

  shared_examples_for "queued index update" do |method_name, path|
    describe "##{method_name}" do
      it "queues updated #{path} for given index" do
        stub_request(:post, "https://example.com/indexes/my_index/#{path}")
          .with(
            body: %w[foo bar baz].to_json
          )
          .to_return(status: 202)

        expect(search.public_send(method_name, :my_index, %w[foo bar baz])).to be true
      end

      it "raises an UnknownResponseStatus exception when an error occurs" do
        stub_request(:post, "https://example.com/indexes/my_index/#{path}")
          .to_return(status: 500)

        expect { search.public_send(method_name, :my_index, %w[foo bar baz]) }
          .to raise_error(described_class::UnknownResponseStatus, /unexpected response status 500/)
      end
    end
  end

  it_behaves_like "queued index update",
                  :store_documents,
                  "documents"

  it_behaves_like "queued index update",
                  :update_searchable_attributes,
                  "settings/searchable-attributes"

  it_behaves_like "queued index update",
                  :update_ranking_rules,
                  "settings/ranking-rules"

  it_behaves_like "queued index update",
                  :update_displayed_attributes,
                  "settings/displayed-attributes"

  describe "#search" do
    before do
      stub_request(:post, "https://example.com/indexes/my_index/search")
        .with(
          body: { q: "my query", limit: 1000 }.to_json
        )
        .to_return(
          status: 200,
          body:   {
            hits: [
              { permalink: "one" },
              { permalink: "two" },
            ],
          }.to_json
        )
    end

    it "returns matching permalinks for given index and query" do
      expect(search.search(:my_index, "my query")).to be == %w[one two]
    end
  end
end
