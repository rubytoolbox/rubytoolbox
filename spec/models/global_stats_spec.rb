# frozen_string_literal: true

require "rails_helper"

RSpec.describe GlobalStats, type: :model do
  let(:stats) { described_class.new }

  describe "#rank" do
    it "is nil for unknown metric" do
      expect(stats.rank(:widget_count, 0)).to be nil
    end

    it "is 1 when value is 0 in bottom bucket" do
      expect(stats.rank(:rubygem_downloads, 0)).to be == 1
    end

    it "is 2 when value falls in second bucket" do
      expect(stats.rank(:rubygem_downloads, 7500)).to be == 2
    end

    it "is 3 when value falls in third bucket" do
      expect(stats.rank(:rubygem_downloads, 25_000)).to be == 3
    end

    it "is 4 when value falls in fourth bucket" do
      expect(stats.rank(:rubygem_downloads, 100_000)).to be == 4
    end

    it "is 5 when value falls in top group for given metric" do
      expect(stats.rank(:rubygem_downloads, 1_250_001)).to be == 5
    end
  end
end
