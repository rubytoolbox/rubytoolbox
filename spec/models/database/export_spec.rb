# frozen_string_literal: true

require "rails_helper"

RSpec.describe Database::Export do
  it { is_expected.to have_attributes(file: kind_of(ActiveStorage::Attached::One)) }

  describe ".latest" do
    subject(:latest) { described_class.latest }

    let(:first) { instance_double described_class }

    before do
      allow(described_class).to receive(:order)
        .with(created_at: :desc)
        .and_return instance_double(described_class.all.class, first:)
    end

    it { is_expected.to be first }
  end
end
