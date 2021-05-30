# frozen_string_literal: true

require "rails_helper"

RSpec.describe RubygemDependency, type: :model do
  subject(:model) { described_class.new }

  describe described_class::Collection do
    describe "#present?" do
      it "is true when a development dependency is there" do
        expect(described_class.new(development: [1], runtime: [])).to be_present
      end

      it "is true when a runtime dependency is there" do
        expect(described_class.new(development: [], runtime: [1])).to be_present
      end

      it "is false when no dependencies are reported" do
        expect(described_class.new(development: [], runtime: [])).not_to be_present
      end
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:rubygem) }

    it "belongs to dependency optionally" do
      expect(model).to belong_to(:dependency)
        .class_name("Rubygem")
        .with_foreign_key(:dependency_name)
        .optional
        .inverse_of(:reverse_dependencies)
    end

    it "belongs to dependency_project" do
      expect(model).to belong_to(:dependency_project)
        .class_name("Project")
        .with_foreign_key(:dependency_name)
        .inverse_of(false)
        .optional
    end
  end

  it { is_expected.to validate_inclusion_of(:type).in_array(described_class::TYPES) }

  describe ".for_project" do
    let(:project) { instance_double Project }

    it "is an empty RubygemDependency::Collection when project has no rubygem name" do
      allow(project).to receive(:rubygem_name)
      expect(described_class.for_project(project))
        .to be_a(described_class::Collection)
        .and have_attributes(development: [], runtime: [])
    end

    describe "when the project has a rubygem_name" do
      let(:base_scope) do
        described_class.where(rubygem_name: project.rubygem_name).preloaded_for_health_status
      end

      before do
        allow(project).to receive(:rubygem_name).and_return(SecureRandom.hex(8))
      end

      it "is a Collection" do
        expect(described_class.for_project(project))
          .to be_a(described_class::Collection)
      end

      it "contains expected development dependencies query" do
        expect(described_class.for_project(project).development.to_sql)
          .to be == base_scope.development.to_sql
      end

      it "contains expected runtime dependencies query" do
        expect(described_class.for_project(project).runtime.to_sql)
          .to be == base_scope.runtime.to_sql
      end
    end
  end
end
