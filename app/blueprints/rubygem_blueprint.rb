# frozen_string_literal: true

class RubygemBlueprint < ApplicationBlueprint
  identifier :name

  fields :current_version,
         :first_release_on,
         :latest_release_on,
         :licenses,
         :url

  field :stats do |gem|
    {
      downloads:                  gem.downloads,
      reverse_dependencies_count: gem.reverse_dependencies_count,
      quarterly_release_counts:   gem.quarterly_release_counts,
      releases_count:             gem.releases_count,
    }
  end
end
