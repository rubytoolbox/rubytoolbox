# frozen_string_literal: true

class CategoryBlueprint < ApplicationBlueprint
  identifier :permalink

  fields :name, :description

  association :category_group, blueprint: CategoryGroupBlueprint

  field :urls do |category, options|
    {
      toolbox_url: Rails.application.routes.url_helpers.category_url(category, host: options[:root_url]),
    }
  end
end
