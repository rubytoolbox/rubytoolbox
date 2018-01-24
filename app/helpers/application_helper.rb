# frozen_string_literal: true

module ApplicationHelper
  def metric(label, value, icon:)
    render partial: "projects/metric", locals: { label: label, value: value, icon: icon }
  end

  def project_link(label, url, icon:)
    render partial: "projects/link", locals: { label: label, url: url, icon: icon }
  end

  def site_name
    t(:name)
  end

  def tagline
    t(:tagline)
  end

  def title(default: false)
    if !default && content_for(:title).present?
      [content_for(:title), site_name].join(" - ")
    else
      [site_name, tagline].join(" - ")
    end
  end

  def description
    content_for(:description).presence || t(:description)
  end
end
