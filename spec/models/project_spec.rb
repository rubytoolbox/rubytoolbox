# frozen_string_literal: true

require "rails_helper"

RSpec.describe Project, type: :model do
  describe "#score" do
    it "is a random number" do
      expect(described_class.new.score).to be_a Float
    end
  end

  describe "#description" do
    it "is a random string" do
      expect(described_class.new.description).to be_a String
    end
  end
end
