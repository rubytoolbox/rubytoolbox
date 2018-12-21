# frozen_string_literal: true

module ApplicationHelper
  def metric_icon(metric)
    "fa-" + t(:icon, scope: "metrics.#{metric}")
  end

  def metric_label(metric)
    t(:label, scope: "metrics.#{metric}")
  end

  def project_metrics(project, *metrics)
    metrics.map do |metric|
      render partial: "projects/metric", locals: {
        label: metric_label(metric),
        value: project.public_send(metric),
        icon:  metric_icon(metric),
      }
    end.inject(&:+)
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

  DISTANCES = {
    1.week   => "within last week",
    2.weeks  => "within last two weeks",
    1.month  => "within last month",
    3.months => "within last 3 months",
    1.year   => "within last year",
    2.years  => "within last 2 years",
  }.freeze

  def recent_distance_in_words(time)
    return if time.blank?

    matching_distance = DISTANCES.find do |distance, _label|
      time >= distance.ago
    end

    matching_distance&.last || "more than 2 years ago"
  end

  def active_when(controller:)
    "is-active" if controller_name == controller.to_s
  end

  def category_card(category, compact: false, inline: false)
    extra_classes = inline ? %w[inline] : []
    locals = {
      category:      category,
      compact:       compact,
      extra_classes: extra_classes,
    }
    render partial: "components/category_card", locals: locals
  end

  def project_health_tag(health_status)
    render "components/project_health_tag", status: health_status
  end

  def project_order_dropdown(order)
    render "components/project_order_dropdown", order: order
  end

  def landing_hero(title:, image:, &block)
    render "components/landing_hero", title: title, image: image, &block
  end

  def component_example(heading, &block)
    render "components/component_example", heading: heading, &block
  end
end
