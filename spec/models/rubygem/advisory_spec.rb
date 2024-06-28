# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rubygem::Advisory do
  subject(:model) { described_class.new }

  it {
    expect(model).to belong_to(:rubygem)
      .with_primary_key(:name)
      .with_foreign_key(:rubygem_name)
      .inverse_of(:advisories)
  }

  it { expect(model).to validate_presence_of(:date) }
  it { expect(model).to validate_presence_of(:rubygem_name) }
end
