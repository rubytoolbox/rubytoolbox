# frozen_string_literal: true

#
# Utilizes the bundler-audit gem to download the ruby advisory db
# from https://github.com/rubysec/ruby-advisory-db and sync it's data
# into our own `Rubygem::Advisory` model
#
class RubygemAdvisoriesSyncJob < ApplicationJob
  def self.import(advisory)
    # Just in case at some point in the future it doesn't only return
    # advisories that refer to gems we do check the source path for the
    # advisory and return early otherwise
    return :not_a_gem unless advisory.path.include? "/gems/"

    # Bundler::Audit::Advisory doesn't contain the actual gem name, so
    # we have to infer it from the definition source path
    rubygem_name = File.basename(File.dirname(advisory.path))

    return :unknown_gem unless Rubygem.exists?(name: rubygem_name)

    Rubygem::Advisory.find_or_initialize_by(rubygem_name:, identifier: advisory.id).tap do |record|
      # The path is just the local bundler-audit yaml file, so it's not relevant to keep
      record.update! date: advisory.date, advisory_data: advisory.to_h.excluding(:path)
    end
  end

  delegate :import, to: :class

  def perform
    Bundler::Audit::Database.update!
    Bundler::Audit::Database.new.advisories.each { import _1 }
    :complete
  end
end
