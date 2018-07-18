# frozen_string_literal: true

require "rails_helper"

RSpec.describe GithubIgnore, type: :model do
  let(:path) { "foo/bar" }

  describe ".track!" do
    it "creates a tracking record" do
      expect { described_class.track! path }
        .to change { described_class.where(path: path).count }
        .from(0)
        .to(1)
    end

    it "does not create a duplicate tracking record" do
      described_class.track! path
      expect { described_class.track! path }
        .not_to change { described_class.where(path: path).count }
        .from(1)
    end
  end

  describe ".ignored?" do
    it "is false when not ignored" do
      expect(described_class.ignored?(path)).to be false
    end

    it "is true when ignored" do
      described_class.track! path
      expect(described_class.ignored?(path)).to be true
    end
  end

  describe ".expire!" do
    before do
      described_class.track! path
      described_class.find(path).update! created_at: 14.days.ago - 1
      described_class.track! "other/repo"
      described_class.find("other/repo").update! created_at: 14.days.ago + 1
    end

    it "removes any records that have been created more than 14 days ago" do
      expect { described_class.expire! }
        .to change(described_class, :count)
        .from(2)
        .to(1)
    end

    it "allows to specify a custom timeframe" do
      expect { described_class.expire! timeframe: 13.days }
        .to change(described_class, :count)
        .from(2)
        .to(0)
    end
  end
end
