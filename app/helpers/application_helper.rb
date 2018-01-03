# frozen_string_literal: true

module ApplicationHelper
  def metric(label, value, icon:)
    render partial: "projects/metric", locals: { label: label, value: value, icon: icon }
  end
end
