# frozen_string_literal: true

require "rails_helper"

RSpec.describe I18n do
  describe "#metrics" do
    it "has a valid icon for each metric" do
      expect(described_class.t(:metrics).map { |_, t| t }).to all(satisfy { |t| t[:icon].present? })
    end

    it "has a valid label for each metric" do
      expect(described_class.t(:metrics).map { |_, t| t }).to all(satisfy { |t| t[:label].present? })
    end

    it "only has valid metric names" do
      expect(described_class.t(:metrics).map(&:first)).to all(satisfy { |m| Project.new.respond_to? m })
    end
  end
end
