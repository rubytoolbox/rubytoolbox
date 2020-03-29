# frozen_string_literal: true

class CategoryGroupBlueprint < ApplicationBlueprint
  identifier :permalink

  fields :name, :description
end
