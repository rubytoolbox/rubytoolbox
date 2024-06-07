# frozen_string_literal: true

require "rails_helper"

RSpec.describe Database::Export do
  it { is_expected.to have_attributes(file: kind_of(ActiveStorage::Attached::One)) }

  it { is_expected.to delegate_method(:url).to(:file).with_prefix }

  describe ".latest" do
    subject(:latest) { described_class.latest }

    let(:first) { instance_double described_class }

    before do
      allow(described_class).to receive(:order)
        .with(created_at: :desc)
        .and_return instance_double(described_class.all.class, first!: first)
    end

    it { is_expected.to be first }
  end

  describe ".outdated" do
    subject(:outdated) { described_class.outdated.to_sql }

    it { is_expected.to eq described_class.order(created_at: :desc).offset(10).to_sql }
  end
end
