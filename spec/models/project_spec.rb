# frozen_string_literal: true

require "rails_helper"

RSpec.describe Project, type: :model do
  describe "#score" do
    it "is a random number" do
      expect(described_class.new.score).to be_an Integer
    end
  end

  describe "#description" do
    it "is a random string" do
      expect(described_class.new.description).to be_a String
    end
  end

  it "does not allow mismatches between permalink and rubygem name" do
    project = Project.create! permalink: "simplecov"
    expect { project.update_attributes! rubygem_name: "rails" }.to raise_error(
      ActiveRecord::StatementInvalid,
      /check_project_permalink_and_rubygem_name_parity/
    )
  end
end
