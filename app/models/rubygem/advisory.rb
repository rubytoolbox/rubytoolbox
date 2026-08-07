# frozen_string_literal: true

class Rubygem::Advisory < ApplicationRecord
  #
  # Just a simple wrapper on the base data we get from the bundler-audit
  # gem to make it accessible via a real ruby object
  #
  class Info < ApplicationStruct
    # The input data structure for this from upstream is a bit complex, see the
    # fixtures file for an example - we simplify this here somewhat
    VersionRequirements = Types::Strict::Array.of(Types::Strict::String).constructor do |input|
      input.fetch("requirements").map do |(comparison, info)|
        Types::Strict::String["#{comparison} #{info.fetch('version')}"]
      end
    end

    attribute :id, Types::Strict::String
    attribute :url, Types::Strict::String.optional
    attribute :date, Types::Params::Date

    attribute :cve, Types::Strict::String.optional
    attribute :ghsa, Types::Strict::String.optional
    # We make this coercible because those are integers, and hence
    # during conversion they end up as ints on the database
    attribute :osvdb, Types::Coercible::String.optional

    attribute :cvss_v2, Types::Coercible::Float.optional
    attribute :cvss_v3, Types::Coercible::Float.optional
    attribute :criticality, Types::Strict::String.optional

    attribute :title, Types::Strict::String.optional
    attribute :description, Types::Strict::String.optional

    attribute :patched_versions, Types::Strict::Array.of(VersionRequirements)
    attribute :unaffected_versions, Types::Strict::Array.of(VersionRequirements)

    alias identifier id
  end

  belongs_to :rubygem,
             primary_key: :name,
             foreign_key: :rubygem_name,
             inverse_of:  :advisories

  validates :date, presence: true
  validates :rubygem_name, presence: true

  scope :recent, -> { where(date: 3.months.ago..).order(date: :desc) }

  delegate(*Rubygem::Advisory::Info.instance_methods(false).excluding(:id, :date), to: :info)

  def info
    # If the underlying data changes, the info struct would get stale,
    # but that's fine because normally this data is updated out-of-band in the
    # advisory sync job, so no need for adding complex memo busting logic
    @info ||= Info.new advisory_data
  end
end
