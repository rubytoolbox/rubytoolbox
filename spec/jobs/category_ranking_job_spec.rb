# frozen_string_literal: true

require "rails_helper"

RSpec.describe CategoryRankingJob, type: :job do
  let(:job) { described_class.new }

  before do
    category_group = CategoryGroup.create! permalink: "group", name: "group"
    Category.create! name: "A", permalink: "a", category_group: category_group
    b = Category.create! name: "B", permalink: "b", category_group: category_group
    c = Category.create! name: "C", permalink: "c", category_group: category_group

    Project.create! permalink: "C1", score: 20, categories: [c]
    Project.create! permalink: "C2", score: 10, categories: [c]
    Project.create! permalink: "B1", score: 15, categories: [b]
    Project.create! permalink: "B2", score: 3, categories: [b]
  end

  describe "#perform" do
    it "sets expected category ranks" do
      expect { job.perform }
        .to change { Category.by_rank.pluck(:name, :rank) }
        .from([])
        .to([["C", 1], ["B", 2]])
    end

    it "updates the ranks correctly on subsequent runs" do
      described_class.new.perform

      Project.create! permalink: "A1", score: 25, categories: [Category.find("a")]
      Project.create! permalink: "A2", score: 20, categories: [Category.find("a")]

      expect { job.perform }
        .to change { Category.by_rank.pluck(:name) }
        .from(%w[C B])
        .to(%w[A C B])
    end

    it "respects a given custom limit" do
      expect { job.perform(limit: 1) }
        .to change { Category.by_rank.pluck(:name) }
        .to(%w[C])
    end
  end
end
