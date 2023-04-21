# frozen_string_literal: true

require "rails_helper"

RSpec.describe Stats, type: :model do
  fixtures :all

  let(:stats) { described_class.new }
  let(:count) { rand(20_000) }

  describe "#projects_with_categories_count" do
    it "queries the total number of categorized projects" do
      relation = instance_double(ActiveRecord::Relation, count:)
      allow(Project).to receive(:joins).with(:categories).and_return(relation)
      expect(stats.projects_with_categories_count).to be == count
    end
  end

  describe "#rubygems_count" do
    it "queries and returns the total number of gems" do
      allow(Rubygem).to receive(:count).and_return(count)
      expect(stats.rubygems_count).to be == count
    end
  end

  describe "#categories_count" do
    it "queries and returns the total number of categories" do
      allow(Category).to receive(:count).and_return(count)
      expect(stats.categories_count).to be == count
    end
  end
end
