# frozen_string_literal: true

module ApplicationHelper
  def metric(label, value, icon:)
    render partial: "projects/metric", locals: { label: label, value: value, icon: icon }
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
    1.week => "within last week",
    2.weeks => "within last two weeks",
    1.month => "within last month",
    3.months => "within last 3 months",
    1.year => "within last year",
    2.years => "within last 2 years",
  }.freeze

  def recent_distance_in_words(time)
    return if time.blank?

    matching_distance = DISTANCES.find do |distance, _label|
      time >= distance.ago
    end

    matching_distance&.last || "more than 2 years ago"
  end
end
