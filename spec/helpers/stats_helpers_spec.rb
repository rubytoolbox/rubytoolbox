# frozen_string_literal: true

require "rails_helper"

RSpec.describe StatsHelpers, :clean_database do
  fixtures :all

  describe "#percentiles" do
    it "returns a hash of number distribution percentiles" do
      Factories.project "example"
      expect(helper.percentiles(:rubygems, :downloads)).to be_a(Hash)
        .and(satisfy { |h| h.keys == (0..100).to_a.map { |n| "#{n}%" } })
        .and(satisfy { |h| h.values.all?(Numeric) })
    end
  end

  describe "#date_groups" do
    before do
      # Null values must not cause problems...
      Rubygem.create! name: "foo", downloads: 1, current_version: 1

      [2003, 2014, 2014, 2016, 2016, 2016, Time.current.year + 1].each_with_index do |year, i|
        Rubygem.create! name:             i,
                        downloads:        i,
                        current_version:  i,
                        first_release_on: Date.new(year)
      end
    end

    it "returns counts grouped by year in given column" do
      expect(helper.date_groups(:rubygems, :first_release_on)).to eq(
        2014 => 2,
        2016 => 3
      )
    end
  end

  describe "#crop_zero_values" do
    it "excludes all keys with zero values except last one from given hash" do
      input = {
        1 => 0, 3 => "0", 12 => 0, 13 => 1, 14 => 2, 15 => 5
      }
      expect(helper.crop_zero_values(input)).to eq(
        12 => 0,
        13 => 1,
        14 => 2,
        15 => 5
      )
    end
  end
end
