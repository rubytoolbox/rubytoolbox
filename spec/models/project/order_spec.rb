# frozen_string_literal: true

require "rails_helper"

RSpec.describe Project::Order, type: :model do
  describe "#ordered_by" do
    it "is 'score' when passed nil" do
      expect(described_class.new(order: nil).ordered_by).to be == "score"
    end

    it "is 'score' when passed unallowed value" do
      expect(described_class.new(order: "value").ordered_by).to be == "score"
    end
  end

  described_class::DIRECTIONS.each do |order, sql|
    describe "when given order #{order.inspect}" do
      it "has ordered_by #{order.inspect}" do
        expect(described_class.new(order: order).ordered_by).to be == order
      end

      it "has order_sql #{sql.inspect}" do
        expect(described_class.new(order: order).sql).to be == sql
      end

      describe "#is?" do
        it "is true for current order" do
          expect(described_class.new(order: order).is?(order)).to be true
        end

        it "is false for other string" do
          expect(described_class.new(order: order).is?(order.upcase)).to be false
        end
      end
    end
  end

  describe "#available_directions" do
    it "is a list of all valid ordered_by keys" do
      expect(described_class.new(order: nil).available_directions).to be == described_class::DIRECTIONS.keys
    end
  end

  describe "#available_groups" do
    it "has three groups: default, rubygem and github_repo" do
      expect(described_class.new(order: nil).available_groups.keys).to be == %w[default rubygem github_repo]
    end

    def group(name)
      described_class.new(order: nil).available_groups[name]
    end

    RUBYGEM_DIRECTIONS = described_class::DIRECTIONS.keys.select { |key| key.start_with? "rubygem_" }

    it "contains exactly #{RUBYGEM_DIRECTIONS.to_sentence} for rubygem group" do
      expect(group("rubygem")).to be == RUBYGEM_DIRECTIONS
    end

    GITHUB_REPO_DIRECTIONS = described_class::DIRECTIONS.keys.select { |key| key.start_with? "github_repo_" }

    it "contains exactly #{GITHUB_REPO_DIRECTIONS.to_sentence} for github_repo group" do
      expect(group("github_repo")).to be == GITHUB_REPO_DIRECTIONS
    end

    DEFAULT_DIRECTIONS = %w[score].freeze

    it "contains exactly #{DEFAULT_DIRECTIONS.to_sentence} for default group" do
      expect(group("default")).to be == DEFAULT_DIRECTIONS
    end
  end
end
