# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rubygem::CodeStatistic, type: :model do
  subject(:model) { described_class.new }

  describe "associations" do
    it do
      expect(model).to belong_to(:rubygem)
        .with_primary_key(:name)
        .with_foreign_key(:rubygem_name)
        .inverse_of(:code_statistics)
    end
  end
end
