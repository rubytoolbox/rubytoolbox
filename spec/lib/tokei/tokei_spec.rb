# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tokei do
  described_class::PLATFORMS.each do |platform|
    context "when arch is '#{platform.arch}'" do
      subject(:platform) { platform }

      it { is_expected.to be_checksum_valid }

      describe ".path" do
        subject(:path) { described_class.new(platform.arch).path }

        it { is_expected.to be == described_class::BIN_BASE_PATH.join(platform.executable) }
      end
    end
  end

  context "when arch is unknown" do
    it { expect { described_class.new("wat").path }.to raise_error described_class::UnknownPlatformError }
  end

  describe "#stats(target)" do
    subject(:stats) { described_class.new.stats(Rails.root.join("lib")) }

    it { pp stats }
  end
end
