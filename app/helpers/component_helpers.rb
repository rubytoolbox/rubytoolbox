# frozen_string_literal: true

#
# Shorthand methods for displaying UI components. See /pages/components
#
module ComponentHelpers
  def category_card(category, compact: false, inline: false)
    extra_classes = inline ? %w[inline] : []
    locals = {
      category:      category,
      compact:       compact,
      extra_classes: extra_classes,
    }
    render "components/category_card", locals
  end

  def render_project(project, show_categories: false, compact: false)
    render "components/project", project: project, show_categories: show_categories, compact: compact
  end

  def project_links(project, compact: false)
    render "components/project/links", project: project, compact: compact
  end

  def project_metrics(project, expanded_view: false, compact: false)
    render "components/project/metrics", project: project, expanded_view: expanded_view, compact: compact
  end

  def metrics_row(project, *metrics)
    metrics.map do |metric|
      render partial: "components/project/metric", locals: {
        key:   metric,
        value: project.public_send(metric),
        icon:  metric_icon(metric),
      }
    end.inject(&:+)
  end

  def project_link(label, url, icon:)
    render "components/project/link", label: label, url: url, icon: icon
  end

  def project_list(projects, title:, metrics: [], description: nil)
    render "components/project/list", projects:    projects,
                                      title:       title,
                                      metrics:     metrics,
                                      description: description
  end

  def project_health_tags(project)
    render "components/project_health_tags", project: project
  end

  def project_health_tag(health_status)
    render "components/project_health_tag", status: health_status
  end

  def small_health_indicator(project)
    render "components/small_health_indicator", project: project
  end

  def project_details_buttons(project)
    render "components/project/details_buttons", project: project
  end

  def project_order_dropdown(order)
    render "components/project_order_dropdown", order: order
  end

  def project_comparison(projects)
    render "components/project_comparison", projects: projects
  end

  def trending_project_card(trend)
    render "components/trending_project_card", trend: trend
  end

  def section_heading(title, description: nil, help_path: nil, &block)
    help_page = docs.find help_path
    render "components/section_heading", title: title, description: description, help_page: help_page, &block
  end

  def project_display_picker(display_mode)
    render "components/project_display_picker", display_mode: display_mode
  end

  def rubygem_download_chart(name)
    return if name.blank?

    stats = Rubygem::DownloadStat::Timeseries.fetch name, :total_downloads, :absolute_change_month
    render "components/rubygem_download_chart", stats: stats
  end

  def line_chart(data, scale: "logarithmic")
    render "components/line_chart",
           keys:   data.keys,
           values: data.values,
           scale:  scale
  end

  def bar_chart(data, small: false)
    render "components/bar_chart",
           keys:   data.keys,
           values: data.values,
           small:  small
  end

  def landing_hero(title:, image:, &block)
    render "components/landing_hero", title: title, image: image, &block
  end

  def landing_feature(title:, image:, &block)
    render "components/landing_feature", title: title, image: image, &block
  end

  def documentation_page(title, &block)
    render "components/documentation_page", title: title, &block
  end

  def component_example(heading, &block)
    render "components/component_example", heading: heading, &block
  end
end
