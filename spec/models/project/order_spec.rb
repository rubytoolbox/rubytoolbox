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
end
