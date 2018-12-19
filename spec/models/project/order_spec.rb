# frozen_string_literal: true

require "rails_helper"

RSpec.describe Project::Order, type: :model do
  describe described_class::Direction do
    describe "#key" do
      it "is a composite of given group and attribute" do
        expect(described_class.new(:foo, :bar).key).to be == "foo_bar"
      end

      it "can be overriden by explicit key keyword argument" do
        expect(described_class.new(:foo, :bar, key: "widgets!").key).to be == "widgets!"
      end
    end

    describe "#sql" do
      it "is constructed from pluralized group, attribute and direction" do
        expect(described_class.new(:foo, :bar).sql).to be == "foos.bar DESC NULLS LAST"
      end

      it "uses custom direction when given" do
        expect(described_class.new(:foo, :bar, direction: :asc).sql).to be == "foos.bar ASC NULLS LAST"
      end
    end
  end

  described_class::DIRECTIONS.each do |direction|
    describe "for order #{direction.key}" do
      let(:order) { described_class.new(order: direction.key) }

      it "has ordered_by #{direction.key}" do
        expect(order.ordered_by).to be == direction.key
      end

      it "has sql based on direction sql" do
        allow(direction).to receive(:sql).and_return("this sql")
        expect(order.sql).to be == "this sql"
      end

      it "returns true for is?(#{direction.key})" do
        expect(order.is?(direction.key)).to be true
      end

      it "returns false for is?('foobar')" do
        expect(order.is?("foobar")).to be false
      end
    end
  end

  DEFAULT_DIRECTION = described_class::DIRECTIONS.find { |d| d.key == "score" }

  describe "for invalid order" do
    let(:order) { described_class.new(order: "lol") }

    it "has ordered_by #{DEFAULT_DIRECTION.key}" do
      expect(order.ordered_by).to be == DEFAULT_DIRECTION.key
    end

    it "has sql based on direction sql" do
      allow(DEFAULT_DIRECTION).to receive(:sql).and_return("this sql")
      expect(order.sql).to be == "this sql"
    end
  end

  describe "#available_groups" do
    EXPECTED_GROUPS = described_class::DIRECTIONS.map(&:group).uniq

    it "has expected groups: #{EXPECTED_GROUPS.to_sentence}" do
      expect(described_class.new(order: nil).available_groups.keys).to be == EXPECTED_GROUPS
    end
  end
end
