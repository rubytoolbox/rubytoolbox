# frozen_string_literal: true

class Rubygem::Advisory < ApplicationRecord
  #
  # Just a simple wrapper on the base data we get from the bundler-audit
  # gem to make it accessible via a real ruby object
  #
  class Info < ApplicationStruct
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

    alias identifier id
  end

  belongs_to :rubygem,
             primary_key: :name,
             foreign_key: :rubygem_name,
             inverse_of:  :advisories

  validates :date, presence: true
  validates :rubygem_name, presence: true

  delegate(*Rubygem::Advisory::Info.instance_methods(false).excluding(:id, :date), to: :info)

  def info
    # If the underlying data changes, the info struct would get stale,
    # but that's fine because normally this data is updated out-of-band in the
    # advisory sync job, so no need for adding complex memo busting logic
    @info ||= Info.new advisory_data
  end
end
