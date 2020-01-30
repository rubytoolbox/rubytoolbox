# frozen_string_literal: true

class CategoryBlueprint < ApplicationBlueprint
  identifier :permalink

  fields :name, :description

  association :category_group, blueprint: CategoryGroupBlueprint
end
