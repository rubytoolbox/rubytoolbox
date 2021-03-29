# frozen_string_literal: true

class RubygemDependency < ApplicationRecord
  self.inheritance_column = nil

  TYPES = %w[runtime development].freeze

  belongs_to :rubygem,
             foreign_key: :rubygem_name,
             inverse_of:  :rubygem_dependencies
  belongs_to :dependency, class_name: "Rubygem", optional: true

  validates :type, inclusion: { in: TYPES }

  TYPES.each do |type|
    scope type, -> { where(type: type) }
  end
end
