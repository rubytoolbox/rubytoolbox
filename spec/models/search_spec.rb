# frozen_string_literal: true

require "rails_helper"

RSpec.describe Search, type: :model do
  describe "#query" do
    it "is the cleaned up search query" do
      expect(described_class.new(" foo bar ").query).to be == "foo bar"
    end

    it "is nil for blank query" do
      expect(described_class.new(" \n ").query).to be_nil
    end
  end

  describe "#query?" do
    it "is true when a valid query was given" do
      expect(described_class.new("query")).to be_query
    end

    it "is false for a blank query" do
      expect(described_class.new(" \n ")).not_to be_query
    end
  end

  describe "#projects" do
    it "searches projects for the given query" do
      expect(Project).to receive(:search).with("my query", order: kind_of(Project::Order), show_forks: false)
      described_class.new("my query").projects
    end

    it "passes given show_forks value to search query" do
      expect(Project).to receive(:search)
        .with(
          kind_of(String),
          order:      kind_of(Project::Order),
          show_forks: true
        )
      described_class.new("my query", show_forks: "yes").projects
    end

    it "returns the resulting collection" do
      collection = %w[some projects]
      allow(Project).to receive(:search).with("my query", order: kind_of(Project::Order), show_forks: false)
                                        .and_return(collection)
      expect(described_class.new("my query").projects).to be == collection
    end
  end

  describe "#categories" do
    it "searches categories for the given query" do
      expect(Category).to receive(:search).with("my query")
      described_class.new("my query").categories
    end

    it "returns the resulting collection" do
      collection = %w[some projects]
      allow(Category).to receive(:search).with("my query").and_return(collection)
      expect(described_class.new("my query").categories).to be == collection
    end
  end

  describe "#order" do
    it "is a Project::Order with search directions by default" do
      order = instance_double(Project::Order)
      allow(Project::Order).to receive(:new)
        .with(directions: Project::Order::SEARCH_DIRECTIONS)
        .and_return(order)

      expect(Search.new("q").order).to be order
    end
  end
end
