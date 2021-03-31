# frozen_string_literal: true

require "rails_helper"

RSpec.describe RubygemDependency, type: :model do
  subject(:model) { described_class.new }

  describe "associations" do
    it { is_expected.to belong_to(:rubygem) }

    it "belongs to dependency optionally" do
      expect(model).to belong_to(:dependency)
        .class_name("Rubygem")
        .with_foreign_key(:dependency_name)
        .optional
        .inverse_of(:reverse_dependencies)
    end
  end

  it { is_expected.to validate_inclusion_of(:type).in_array(described_class::TYPES) }
end
