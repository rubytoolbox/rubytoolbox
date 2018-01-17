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
      Rubygem.find_or_initialize_by(name: name).tap do |gem|
        # Set updated at to ensure we flag what we've pulled
        gem.updated_at = Time.current.utc
        gem.update_attributes! mapped_info.merge(extra_attributes)
      end
      ProjectUpdateJob.perform_async name
    else
      Rubygem.where(name: name).destroy_all
    end
  end

  private

  ATTRIBUTE_MAPPING = {
    authors: :authors,
    bug_tracker_uri: :bug_tracker_url,
    documentation_uri: :documentation_url,
    downloads: :downloads,
    homepage_uri: :homepage_url,
    info: :description,
    licenses: :licenses,
    mailing_list_uri: :mailing_list_url,
    source_code_uri: :source_code_url,
    version: :current_version,
    wiki_uri: :wiki_url,
  }.freeze

  def mapped_info
    ATTRIBUTE_MAPPING.each_with_object({}) do |(remote_name, local_name), mapped|
      mapped[local_name] = info[remote_name.to_s].presence
    end
  end

  def extra_attributes
    {
      first_release_on: releases.first["built_at"],
      latest_release_on: releases.last["built_at"],
      releases_count: releases.count,
      reverse_dependencies_count: reverse_dependencies.count,
    }
  end

  def reverse_dependencies
    @reverse_dependencies ||= fetch_gem_api_response "gems/#{name}/reverse_dependencies.json"
  end

  def releases
    @releases ||= fetch_gem_api_response("versions/#{name}.json").sort_by { |v| v["built_at"] }
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
