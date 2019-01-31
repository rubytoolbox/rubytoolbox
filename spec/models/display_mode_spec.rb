# frozen_string_literal: true

require "rails_helper"

RSpec.describe DisplayMode, type: :model do
  describe "#current" do
    it "is the default when none requested" do
      expect(DisplayMode.new.current).to be == "full"
    end

    it "is the default when nil requested" do
      expect(DisplayMode.new(nil).current).to be == "full"
    end

    it "is the default when invalid requested" do
      expect(DisplayMode.new("123").current).to be == "full"
    end

    it "is the requested when valid" do
      requested = DisplayMode.new.available.sample
      expect(DisplayMode.new(requested.to_sym).current).to be == requested
    end

    it "is the first when default is invalid" do
      expect(DisplayMode.new(default: "lol").current).to be == DisplayMode.new.available.first
    end
  end
end
