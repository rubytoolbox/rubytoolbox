# frozen_string_literal: true

module ApplicationHelper
  include ComponentHelpers
  include StatsHelpers

  def metric_icon(metric)
    "fa-" + t(:icon, scope: "metrics.#{metric}")
  end

  def metric_label(metric)
    t(:label, scope: "metrics.#{metric}")
  end

  def project_metrics(project, *metrics)
    metrics.map do |metric|
      render partial: "projects/metric", locals: {
        key:   metric,
        value: project.public_send(metric),
        icon:  metric_icon(metric),
      }
    end.inject(&:+)
  end

  # This should be refactored...
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def pretty_metric_value(value)
    if value.is_a?(Float) || value.is_a?(BigDecimal)
      number_with_delimiter(value.floor) + "%"
    elsif value.is_a? Integer
      number_with_delimiter value
    elsif value.is_a?(Date) || value.is_a?(Time)
      content_tag "time", "#{time_ago_in_words(value)} ago", datetime: value.iso8601, title: l(value)
    elsif value.is_a? Array
      value.to_sentence
    else
      value
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def docs
    @docs ||= Docs.new
  end

  def link_to_docs_if_exists(page, &block)
    content = capture(&block)

    if docs.find page
      link_to content, page_path(page)
    else
      content
    end
  end

  def project_link(label, url, icon:)
    render partial: "projects/link", locals: { label: label, url: url, icon: icon }
  end

  # why
  # https://rails.lighthouseapp.com/projects/8994/tickets/4334-to_param-and-resource_path-escapes-forward-slashes
  # https://github.com/rails/rails/issues/16058
  def blog_post_path(post)
    File.join blog_index_path, post.slug
  end

  # See above.
  def blog_post_url(post)
    File.join blog_index_url, post.slug
  end

  # Just to make sure to never mess up using url instead of path or the wrong format.
  def feed_url
    blog_index_url(format: :rss)
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

  def active_when(controller:)
    "is-active" if controller_name == controller.to_s
  end
end
