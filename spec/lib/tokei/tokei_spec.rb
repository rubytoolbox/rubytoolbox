# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tokei do
  before do
    allow(described_class).to receive(:arch).and_return(arch)
  end

  described_class::PLATFORMS.each do |platform|
    context "when arch is '#{platform.arch}'" do
      subject(:platform) { platform }

      let(:arch) { platform.arch }

      it { is_expected.to be_checksum_valid }

      describe ".path" do
        subject(:path) { described_class.path }

        it { is_expected.to be == described_class::BIN_BASE_PATH.join(platform.executable) }
      end
    end
  end

  context "when arch is unknown" do
    let(:arch) { "wat" }

    it { expect { described_class.path }.to raise_error described_class::UnknownPlatformError }
  end
end
