# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rubygem::Advisory do
  fixtures :all

  subject(:model) { rubygem_advisories(:nokogiri1) }

  it {
    expect(model).to belong_to(:rubygem)
      .with_primary_key(:name)
      .with_foreign_key(:rubygem_name)
      .inverse_of(:advisories)
  }

  it { expect(model).to validate_presence_of(:date) }
  it { expect(model).to validate_presence_of(:rubygem_name) }

  %i[
    criticality
    cve
    cvss_v2
    cvss_v3
    ghsa
    identifier
    osvdb
    title
    url
    description
    patched_versions
    unaffected_versions
  ].each do |property|
    it { is_expected.to delegate_method(property).to(:info) }
  end

  describe "#info" do
    subject(:info) { model.info }

    it { is_expected.to be_a(ApplicationStruct) }

    it do # rubocop:disable RSpec/ExampleLength
      expect(info).to have_attributes(
        id:               "CVE-2019-18197",
        identifier:       "CVE-2019-18197",
        cve:              "2019-18197",
        url:              "https://github.com/sparklemotion/nokogiri/issues/1943",
        date:             Date.new(2022, 5, 24),
        ghsa:             "242x-7cm6-4w8j",
        osvdb:            nil,
        title:            "Nokogiri affected by libxslt Use of Uninitialized Resource/ Use After Free vulnerability",
        cvss_v2:          5.1,
        cvss_v3:          7.5,
        criticality:      "high",
        description:      /\AIn xsltCopyText/,
        patched_versions: [[">= 1.10.5"]]
      )
    end

    describe "for an advisory with complex patched and unaffected versions" do
      let(:model) { rubygem_advisories :actionpack1 }

      it do
        expect(info).to have_attributes(
          patched_versions:    [["~> 5.2.7", ">= 5.2.7.1"], ["~> 6.0.4", ">= 6.0.4.8"], ["~> 6.1.5", ">= 6.1.5.1"],
                                [">= 7.0.2.4"]],
          unaffected_versions: [["< 5.2.0"]]
        )
      end
    end
  end
end
