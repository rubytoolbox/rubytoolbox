# frozen_string_literal: true

require "rails_helper"

RSpec.describe RubygemCodeStatsJob do
  fixtures :all

  subject(:job) { described_class.new }

  let(:rubygem) { rubygems :nokogiri }

  let(:fake_statistics) do
    RubygemCodeStatsService::ResultSet.new(
      "Ruby" => { "code" => 100, "blanks" => 200, "comments" => 300 },
      "C"    => { "code" => 300, "blanks" => 200, "comments" => 100 }
    )
  end

  before do
    allow(RubygemCodeStatsService).to receive(:statistics)
      .with(name: rubygem.name, version: rubygem.current_version)
      .and_return fake_statistics
  end

  describe ".perform" do
    subject(:perform) { job.perform rubygem.name }

    it do
      expect { perform }
        .to change { rubygem.code_statistics.pluck(:language, :code) }
        .from([])
        .to([["c", 300], ["ruby", 100]])
    end

    context "when we have some dropped language in the database" do
      before do
        rubygem.code_statistics.create! language: "no_longer_used_language",
                                        code:     1,
                                        comments: 2,
                                        blanks:   3
      end

      it do
        expect { perform }
          .to change { rubygem.code_statistics.pluck(:language) }
          .from(%w[no_longer_used_language])
          .to(%w[c ruby])
      end
    end
  end
end
