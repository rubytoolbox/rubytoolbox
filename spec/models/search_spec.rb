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
      expect(Project).to receive(:search).with("my query")
      described_class.new("my query").projects
    end

    it "returns the resulting collection" do
      collection = %w[some projects]
      allow(Project).to receive(:search).with("my query").and_return(collection)
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
end
