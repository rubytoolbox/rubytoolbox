# frozen_string_literal: true

require "rails_helper"

RSpec.describe Search::QueryCheck do
  describe "#runnable?" do
    it "is true for a regular query" do
      expect(described_class.new("rails authentication")).to be_runnable
    end

    it "is false for a blank query" do
      expect(described_class.new(" \n ")).not_to be_runnable
    end

    it "is false for a nil query" do
      expect(described_class.new(nil)).not_to be_runnable
    end

    it "is true for a query at the maximum allowed length" do
      expect(described_class.new("a" * described_class::MAX_QUERY_LENGTH)).to be_runnable
    end

    it "is false for a query exceeding the maximum allowed length" do
      expect(described_class.new("a" * (described_class::MAX_QUERY_LENGTH + 1))).not_to be_runnable
    end

    it "is true for a query at the maximum allowed token count" do
      query = Array.new(described_class::MAX_QUERY_TOKENS) { |i| "t#{i}" }.join(" ")
      expect(described_class.new(query)).to be_runnable
    end

    it "is false for a query exceeding the maximum allowed token count" do
      query = Array.new(described_class::MAX_QUERY_TOKENS + 1) { |i| "t#{i}" }.join(" ")
      expect(described_class.new(query)).not_to be_runnable
    end

    it "is false for spammy punctuation-separated phrase lists" do
      # Mirrors bot spam that packs many short phrases separated by
      # punctuation, which counts as many tokens even when fairly short.
      expect(described_class.new("aa,bb,cc,dd,ee,ff,gg,hh,ii")).not_to be_runnable
    end
  end

  describe "#abusive?" do
    it "is false for a blank query" do
      expect(described_class.new(" \n ")).not_to be_abusive
    end

    it "is false for a regular query" do
      expect(described_class.new("rails authentication")).not_to be_abusive
    end

    it "is true for an over-long query" do
      expect(described_class.new("a" * (described_class::MAX_QUERY_LENGTH + 1))).to be_abusive
    end

    it "is true for a query with too many tokens" do
      query = Array.new(described_class::MAX_QUERY_TOKENS + 1) { |i| "t#{i}" }.join(" ")
      expect(described_class.new(query)).to be_abusive
    end
  end
end
