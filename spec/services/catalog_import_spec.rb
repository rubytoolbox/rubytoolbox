# frozen_string_literal: true

require "rails_helper"

RSpec.describe CatalogImport, type: :service do
  describe ".perform" do
    let(:import) do
      instance_double(described_class, perform: nil)
    end

    it "initializes a new instance with given catalog data" do
      expect(described_class).to receive(:new).with("data").and_return(import)
      described_class.perform "data"
    end

    it "calls perform on the import instance" do
      allow(described_class).to receive(:new).and_return(import)
      expect(import).to receive(:perform)
      described_class.perform "data"
    end
  end
end
