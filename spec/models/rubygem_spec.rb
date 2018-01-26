# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rubygem, type: :model do
  describe ".update_batch" do
    before do
      Rubygem.create! name: "up-to-date", downloads: 50, current_version: "1.0.0", updated_at: 23.hours.ago
      Rubygem.create! name: "outdated1", downloads: 50, current_version: "1.0.0", updated_at: 27.hours.ago
      Rubygem.create! name: "outdated2", downloads: 50, current_version: "1.0.0", updated_at: 26.hours.ago
    end

    it "contains a subset of gems that should be updated" do
      expect(described_class.update_batch).to match %w[outdated1]
    end

    it "the subset grows with to the total count of gems" do
      24.times do |i|
        Rubygem.create! name: "outdated#{i + 3}", downloads: 50, current_version: "1.0.0", updated_at: 25.hours.ago
      end

      expect(described_class.update_batch).to match %w[outdated1 outdated2]
    end
  end

  describe "#url" do
    it "is derived from the gem name" do
      expect(Rubygem.new(name: "foobar").url).to be == "https://rubygems.org/gems/foobar"
    end
  end

  describe "#documentation_url" do
    it "is the gem's documentation_url if set" do
      url = "https://api.rubyonrails.org"
      expect(Rubygem.new(documentation_url: url).documentation_url).to be == url
    end

    it "falls back to rubydoc.info if not set in gem metadata" do
      expect(Rubygem.new(name: "rails").documentation_url).to be == "http://www.rubydoc.info/gems/rails/frames"
    end
  end
end
