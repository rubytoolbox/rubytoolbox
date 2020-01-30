# frozen_string_literal: true

require "rails_helper"

RSpec.describe Docs do
  let(:docs) { described_class.new }

  describe described_class::Page do
    let(:page) { described_class.new("foo/bar/baz") }

    describe "#title" do
      it "is fetched from I18n" do
        allow(I18n).to receive(:t).with("baz", scope: "docs.titles").and_return("Hello World")
        expect(page.title).to be == "Hello World"
      end
    end

    describe "#section" do
      it "is the parent directory name of given id" do
        expect(page.section).to be == "bar"
      end
    end

    describe "#active?" do
      it "is true when given id matches page id" do
        expect(page.active?("foo/bar/baz")).to be true
      end

      it "is false when given id does not match page id" do
        expect(page.active?("foo/bar/blurb")).to be false
      end
    end

    describe "#to_param" do
      it "is an alias for the id" do
        expect(page.to_param).to be == page.id
      end
    end
  end

  it "has titles for all existing docs pages" do
    titles = docs.sections.map(&:last).flatten.map(&:title)
    expect(titles).to all(be_present)
      .and(all(satisfy { |title| !title.include? "missing" }))
  end

  describe "#find(id)" do
    it "returns page with given id" do
      expect(docs.find("docs/features/bugfix_forks"))
        .to be_a(described_class::Page)
        .and(have_attributes(id: "docs/features/bugfix_forks"))
    end
  end

  describe "#sections" do
    it "has expected sections" do
      expect(docs.sections.keys).to be == %w[Guides Features API Metrics]
    end

    it "has pages" do
      expect(docs.sections.map(&:last).flatten.count).to be > 3
    end

    it "has Page instances within values" do
      expect(docs.sections.map(&:last).flatten).to all(be_a(described_class::Page))
    end
  end
end
