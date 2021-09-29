# frozen_string_literal: true

require "rails_helper"

RSpec.describe DisplayMode, type: :model do
  fixtures :all

  describe "#current" do
    it "is the default when none requested" do
      expect(described_class.new.current).to be == "full"
    end

    it "is the default when nil requested" do
      expect(described_class.new(nil).current).to be == "full"
    end

    it "is the default when invalid requested" do
      expect(described_class.new("123").current).to be == "full"
    end

    it "is the requested when valid" do
      requested = described_class.new.available.sample
      expect(described_class.new(requested.to_sym).current).to be == requested
    end

    it "is the first when default is invalid" do
      expect(described_class.new(default: "lol").current).to be == described_class.new.available.first
    end
  end
end
