# frozen_string_literal: true

#
# This sidekiq background job takes care of syncing the data
# of one individual rubygem from rubygems.org to the local
# mirror db
#
class RubygemUpdateJob < ApplicationJob
  attr_accessor :name
  private :name=

  def perform(name)
    # This is not nice, but imposed by sidekiq, and we don't want
    # to carry around all that state through all method signatures.
    # It might make sense to make this job a thin wrapper around
    # an actual, proper ruby class that just calls RubygemUpdateService.new(name).perform
    self.name = name

    if info
      changes = perform_updates!

      queue_followups! changes
    else
      Rubygem.where(name: name).destroy_all
    end
  end

  private

  def perform_updates!
    Rubygem.transaction do
      changes = update_gem_data!
      sync_dependencies!

      changes
    end
  end

  def queue_followups!(changes)
    ProjectUpdateJob.perform_async name
    # Since downloading the gem fully is a bit more involved we only want to do
    # it whenever a new version was released
    RubygemCodeStatsJob.perform_async name if changes.key?("current_version")
  end

  def update_gem_data!
    Rubygem.find_or_initialize_by(name: name).tap do |gem|
      # Set updated at to ensure we flag what we've pulled
      gem.updated_at = gem.fetched_at = Time.current.utc
      gem.quarterly_release_counts = quarterly_releases
      gem.update! mapped_info.merge(extra_attributes)

      return gem.previous_changes
    end
  end

  ATTRIBUTE_MAPPING = {
    authors:           :authors,
    bug_tracker_uri:   :bug_tracker_url,
    documentation_uri: :documentation_url,
    downloads:         :downloads,
    homepage_uri:      :homepage_url,
    info:              :description,
    licenses:          :licenses,
    mailing_list_uri:  :mailing_list_url,
    source_code_uri:   :source_code_url,
    version:           :current_version,
    wiki_uri:          :wiki_url,
  }.freeze

  def mapped_info
    ATTRIBUTE_MAPPING.each_with_object({}) do |(remote_name, local_name), mapped|
      mapped[local_name] = info[remote_name.to_s].presence
    end
  end

  def extra_attributes
    {
      first_release_on:           releases.first["built_at"],
      latest_release_on:          releases.last["built_at"],
      releases_count:             releases.count,
      reverse_dependencies_count: reverse_dependencies.count,
    }
  end

  def reverse_dependencies
    @reverse_dependencies ||= fetch_gem_api_response "gems/#{name}/reverse_dependencies.json"
  end

  def releases
    @releases ||= fetch_gem_api_response("versions/#{name}.json").sort_by { |v| v["built_at"] }
  end

  def quarterly_releases
    grouped_by_quarter = releases.uniq { |r| r["number"] }.group_by do |r|
      built = Time.zone.parse(r["built_at"])
      "#{built.year}-#{(built.month / 3.0).ceil}"
    end

    grouped_by_quarter.transform_values(&:count)
  end

  def sync_dependencies!
    return unless info["dependencies"]

    known = info["dependencies"].flat_map do |type, dependencies|
      dependencies.map do |dependency|
        sync_dependency! dependency_name: dependency.fetch("name"),
                         type:            type,
                         requirements:    dependency.fetch("requirements")
      end
    end

    RubygemDependency.where(rubygem_name: name).where.not(id: known).delete_all
  end

  def sync_dependency!(dependency_name:, type:, requirements:)
    RubygemDependency.find_or_initialize_by(rubygem_name: name, dependency_name: dependency_name,
                                            type: type).tap do |dependency|
      dependency.update!(requirements: requirements)
    end
  end

  def info
    @info ||= fetch_gem_api_response "gems/#{name}.json"
  end

  def fetch_gem_api_response(path)
    url = File.join "https://rubygems.org/api/v1", path
    response = HttpService.client.get url

    return nil if response.status == 404
    return JSON.parse(response.body) if response.status == 200

    raise "Unknown response status #{response.status.to_i}"
  end
end
