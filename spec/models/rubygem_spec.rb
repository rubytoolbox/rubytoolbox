# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rubygem do
  fixtures :all

  subject(:model) { described_class.new }

  describe "associations" do
    it { is_expected.to have_one(:project) }
    it { is_expected.to have_many(:advisories).order(date: :desc) }
    it { is_expected.to have_many(:download_stats).order(date: :asc) }
    it { is_expected.to have_many(:trends).order(date: :asc) }
    it { is_expected.to have_many(:rubygem_dependencies).order(dependency_name: :asc).dependent(:destroy) }

    it "has_many rubygem_dependencies" do
      expect(model).to have_many(:reverse_dependencies)
        .order(rubygem_name: :asc)
        .dependent(:destroy)
    end

    it do
      expect(model).to have_many(:code_statistics)
        .order(language: :asc)
        .with_foreign_key(:rubygem_name)
        .class_name("Rubygem::CodeStatistic")
    end
  end

  describe ".update_batch" do
    subject(:scope) { described_class.update_batch.to_sql }

    let(:expected_sql) do
      described_class.where("fetched_at < ? ", 24.hours.ago.utc)
                     .order(fetched_at: :asc)
                     .limit((described_class.count / 24.0).ceil)
                     .to_sql
    end

    around do |example|
      Timecop.freeze Time.current do
        example.run
      end
    end

    it { is_expected.to eq expected_sql }
  end

  describe "#url" do
    it "is derived from the gem name" do
      expect(described_class.new(name: "foobar").url).to eq "https://rubygems.org/gems/foobar"
    end
  end

  describe "#documentation_url" do
    it "is the gem's documentation_url if set" do
      url = "https://api.rubyonrails.org"
      expect(described_class.new(documentation_url: url).documentation_url).to eq url
    end

    it "falls back to rubydoc.info if not set in gem metadata" do
      expected = "http://www.rubydoc.info/gems/rails/frames"
      expect(described_class.new(name: "rails").documentation_url).to eq expected
    end
  end
end
