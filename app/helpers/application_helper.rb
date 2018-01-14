# frozen_string_literal: true

module ApplicationHelper
  def metric(label, value, icon:)
    render partial: "projects/metric", locals: { label: label, value: value, icon: icon }
  end

  def title
    ["The Ruby Toolbox", content_for(:title).presence || "Know your options!"].join(" - ")
  end

  def description
    content_for(:description).presence || "Explore and compare open source Ruby libraries"
  end
end
