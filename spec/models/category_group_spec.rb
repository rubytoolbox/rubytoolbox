# frozen_string_literal: true

require "rails_helper"

RSpec.describe CategoryGroup, type: :model do
  describe ".for_welcome_page" do
    it "returns all CategoryGroups ordered by name" do
      described_class.create! [
        { permalink: "one", name: "Group1" },
        { permalink: "two", name: "Group2" },
        { permalink: "three", name: "Group3" },
      ]
      expect(described_class.for_welcome_page.pluck(:name)).to be == %w[Group1 Group2 Group3]
    end
  end
end
