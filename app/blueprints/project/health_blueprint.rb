# frozen_string_literal: true

class Project::HealthBlueprint < ApplicationBlueprint
  class StatusBlueprint < ApplicationBlueprint
    identifier :key

    fields :level, :icon, :label
  end

  field :overall_level

  association :status, name: :statuses, blueprint: StatusBlueprint
end
