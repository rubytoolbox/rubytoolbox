# frozen_string_literal: true

require "rails_helper"

RSpec.describe RubygemAdvisoriesSyncJob do
  fixtures :all

  subject(:job) { described_class.new }

  describe ".import(advisory)" do
    subject(:import) { described_class.import advisory }

    let(:path) { "/gems/nokogiri/example.yaml" }
    let(:advisory) do
      instance_double Bundler::Audit::Advisory,
                      path:,
                      id:   "FOO-123",
                      date: Time.zone.today,
                      to_h: { the: "data", path: "local at import, so excluded" }
    end

    let(:advisory_count) do
      lambda do
        Rubygem::Advisory.where(
          rubygem_name:  "nokogiri",
          identifier:    advisory.id,
          date:          advisory.date,
          advisory_data: advisory.to_h.excluding(:path)
        ).count
      end
    end

    it "persists the given advisory in the database" do
      expect { import }.to change(&advisory_count).from(0).to(1)
    end

    it { is_expected.to be_a Rubygem::Advisory }

    context "when the advisory already exists" do
      let!(:existing_advisory) do
        Rubygem::Advisory.create! rubygem_name: "nokogiri", identifier: advisory.id, date: 3.years.ago
      end

      it { expect { import }.not_to change(Rubygem::Advisory, :count) }

      it "updates the existing record in place" do
        advisory_data = advisory.to_h.excluding(:path).stringify_keys

        import
        expect(existing_advisory.reload).to have_attributes(date:          advisory.date,
                                                            advisory_data:)
      end
    end

    context "when the gem is not in our database" do
      let(:path) { "/foo/gems/very_unknown404/foo.yaml" }

      it { is_expected.to eq :unknown_gem }
      it { expect { import }.not_to change(Rubygem::Advisory, :count) }
    end

    context "when the path does not include a gems subdirectory" do
      let(:path) { "hmmmmmmmm" }

      it { is_expected.to eq :not_a_gem }
      it { expect { import }.not_to change(Rubygem::Advisory, :count) }
    end
  end

  describe ".perform" do
    subject(:perform) { job.perform }

    let(:database) { instance_double Bundler::Audit::Database, advisories: }

    let(:advisories) { Array.new(1) { instance_double Bundler::Audit::Advisory } }

    before do
      allow(Bundler::Audit::Database).to receive(:update!)
      allow(Bundler::Audit::Database).to receive(:new).and_return database
      allow(described_class).to receive(:import).with(advisories.first)
    end

    it { is_expected.to eq :complete }

    it "performs a local database update" do
      expect(Bundler::Audit::Database).to receive(:update!)
      perform
    end

    it "imports each advisory" do
      expect(described_class).to receive(:import).with(advisories.first)
      perform
    end
  end
end
