# frozen_string_literal: true

require "rails_helper"

RSpec.describe RubygemCodeStatsService, type: :service do
  let(:service) { described_class.new(name: name, version: version) }
  let(:name) { "oj" }
  let(:version) { "3.13.9" }
  let(:gem_file) { file_fixture "#{name}-#{version}.gem" }

  describe ".statistics" do
    subject(:statistics) { described_class.statistics name: name, version: version }

    let(:instance) do
      instance_double described_class, statistics: SecureRandom.hex(5)
    end

    before do
      allow(described_class).to receive(:new)
        .with(name: name, version: version)
        .and_return instance
    end

    it { is_expected.to be instance.statistics }
  end

  describe "#statistics" do
    subject(:statistics) { service.statistics }

    let(:expected_statistics) do
      {}
    end

    before do
      stub_request(:get, service.gem_download_url)
        .to_return(status: 200, body: gem_file.read)
    end

    it { is_expected.to be_a(described_class::ResultSet).and have_attributes(count: 4) }

    it do # rubocop:disable RSpec/ExampleLength Since extraction is a bit expensive better verify in one swoop
      expect(statistics).to include(
        have_attributes(
          language: "c",
          blanks:   be_within(500).of(2000),
          code:     be_within(1000).of(19_000),
          comments: be_within(500).of(1500)
        )
      ).and include(
        have_attributes(
          language: "ruby",
          blanks:   be_within(50).of(100),
          code:     be_within(250).of(750),
          comments: be_within(100).of(300)
        )
      ).and include(
        have_attributes(
          language: "markdown",
          code:     0,
          comments: be_within(250).of(1700)
        )
      ).and include(
        have_attributes(
          language: "c_header",
          code:     be_within(100).of(1100)
        )
      )
    end
  end
end
