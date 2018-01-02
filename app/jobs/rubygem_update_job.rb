# frozen_string_literal: true

class RubygemUpdateJob < ApplicationJob
  def perform(name)
    info = fetch_gem_info name

    if info
      Rubygem.find_or_initialize_by(name: name).tap do |gem|
        gem.update_attributes! mapped_attributes(info)
      end
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

  def mapped_attributes(info)
    ATTRIBUTE_MAPPING.each_with_object({}) do |(remote_name, local_name), mapped|
      mapped[local_name] = info[remote_name.to_s].presence
    end
  end

  def fetch_gem_info(name)
    url = File.join("https://rubygems.org/api/v1/gems", "#{name}.json")
    response = HttpService.client.get url

    return nil if response.status == 404
    return Oj.load(response.body)  if response.status == 200

    raise "Unknown response status #{response.status.to_i}"
  end
end
