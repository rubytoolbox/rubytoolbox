# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rubygem::DownloadStat::Navigation, type: :model do
  let(:rubygem) { Factories.rubygem "example" }

  before do
    Factories.rubygem_trend rubygem.name, date: 56.weeks.ago, position: 1
    Factories.rubygem_trend rubygem.name, date: 8.weeks.ago, position: 1
    Factories.rubygem_trend rubygem.name, date: 4.weeks.ago, position: 1
    Factories.rubygem_trend rubygem.name, date: 3.weeks.ago, position: 1
    Factories.rubygem_trend rubygem.name, date: 1.week.ago, position: 1
    Factories.rubygem_trend rubygem.name, date: Time.current, position: 1
  end

  describe ".find" do
    it "returns an instance with given date when exact match exists" do
      expect(described_class.find(Time.current.to_date).date).to be == Time.current.to_date
    end

    it "returns closest higher date when no exact match exists" do
      expect(described_class.find(9.weeks.ago).date).to be == 8.weeks.ago.to_date
    end

    it "returns closest lower date when no exact match or later date exists" do
      expect(described_class.find(1.year.from_now).date).to be == Time.current.to_date
    end

    it "returns highest available date for invalid value" do
      expect(described_class.find("foobar").date).to be == Time.current.to_date
    end
  end

  describe ".latest_date" do
    it "is the latest available date" do
      allow(Rubygem::Trend).to receive(:maximum).and_return(Date.new(2019, 2, 24))
      expect(described_class.latest_date).to be == Date.new(2019, 2, 24)
    end
  end

  describe "for date 4 weeks ago" do
    let(:navigation) { described_class.new 4.weeks.ago.to_date }

    {
      previous_year:  56.weeks.ago.to_date,
      previous_month: 8.weeks.ago.to_date,
      previous_week:  5.weeks.ago.to_date,
      next_week:      3.weeks.ago.to_date,
      next_month:     Time.current.to_date,
      next_year:      nil,
    }.each do |method_name, expected_date|
      it "has #{expected_date.inspect} for #{method_name}" do
        expect(navigation.public_send(method_name)).to be == expected_date
      end
    end
  end

  describe "for date 56 weeks ago" do
    let(:navigation) { described_class.new 56.weeks.ago.to_date }

    {
      previous_year:  nil,
      previous_month: nil,
      previous_week:  nil,
      next_week:      55.weeks.ago.to_date,
      next_month:     52.weeks.ago.to_date,
      next_year:      4.weeks.ago.to_date,
    }.each do |method_name, expected_date|
      it "has #{expected_date.inspect} for #{method_name}" do
        expect(navigation.public_send(method_name)).to be == expected_date
      end
    end
  end

  describe "#exact_match?" do
    {
      "2019-02-13"          => true,
      Date.new(2019, 2, 13) => true,
      Date.new(2018, 2, 13) => false,
      nil                   => false,
      "foo"                 => false,
      "🤣😂"                  => false,
    }.each do |requested_date, expected_result|
      it "is #{expected_result.inspect} when date is 2019-02-13 and requested_date is #{requested_date}" do
        result = described_class.new(Date.new(2019, 2, 13)).exact_match?(requested_date)
        expect(result).to be expected_result
      end
    end
  end

  describe "#latest?" do
    let(:navigation) { described_class.new(Date.new(2019, 2, 20)) }

    it "is true when date is the latest_date" do
      allow(described_class).to receive(:latest_date).and_return(Date.new(2019, 2, 20))
      expect(navigation.latest?).to be true
    end

    it "is false when date is not the latest_date" do
      allow(described_class).to receive(:latest_date).and_return(Date.new(2019, 3, 20))
      expect(navigation.latest?).to be false
    end
  end
end
