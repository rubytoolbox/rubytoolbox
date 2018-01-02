# frozen_string_literal: true

class RubygemInfoJob < ApplicationJob
  def perform(name)
    info = fetch_gem_info name

    if info
      Rubygem.find_or_initialize_by(name: name).tap do |gem|
        gem.update_attributes! description: info["info"],
                               downloads: info["downloads"]
      end
    else
      Rubygem.where(name: name).destroy_all
    end
  end

  private

  def fetch_gem_info(name)
    url = File.join("https://rubygems.org/api/v1/gems", "#{name}.json")
    response = HTTP.get(url)

    return nil if response.status == 404
    return Oj.load(response.body)  if response.status == 200

    raise "Unknown response status #{response.status}"
  end
end
