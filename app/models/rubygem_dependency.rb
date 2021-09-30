# frozen_string_literal: true

class RubygemDependency < ApplicationRecord
  class Collection
    attr_reader :development, :runtime
    private attr_writer :development, :runtime

    def initialize(development:, runtime:)
      self.development = development
      self.runtime = runtime
    end

    def present?
      development.any? || runtime.any?
    end
  end

  self.inheritance_column = nil

  TYPES = %w[development runtime].freeze

  belongs_to :rubygem,
             foreign_key: :rubygem_name,
             inverse_of:  :rubygem_dependencies
  belongs_to :dependency,
             class_name:  "Rubygem",
             foreign_key: :dependency_name,
             inverse_of:  :reverse_dependencies,
             # Optional because we might not know about this gem
             optional:    true

  belongs_to :depending_project,
             class_name:  "Project",
             optional:    true,
             foreign_key: :rubygem_name,
             primary_key: :rubygem_name,
             inverse_of:  false

  belongs_to :dependency_project,
             class_name:  "Project",
             optional:    true,
             foreign_key: :dependency_name,
             primary_key: :rubygem_name,
             inverse_of:  false

  validates :type, inclusion: { in: TYPES }

  TYPES.each do |type|
    scope type, -> { where(type: type) }
  end

  scope :preloaded_for_health_status, lambda {
    # We have to preload the associated records to report the health status
    # badges alongside it in the UI
    includes(dependency_project: %i[rubygem github_repo])
  }

  #
  # Retrieves the sets of dependencies for the given project wrapped in
  # a RubygemDependency::Collection with associations preloaded to
  # easily assess project health status based on the returned data
  #
  def self.for_project(project)
    return Collection.new(development: [], runtime: []) if project.rubygem_name.blank?

    base_scope = where(rubygem_name: project.rubygem_name).strict_loading.preloaded_for_health_status

    Collection.new(
      development: base_scope.development,
      runtime:     base_scope.runtime
    )
  end
end
