# frozen_string_literal: true

#
# Shorthand methods for displaying UI components. See /pages/components
# rubocop:disable Metrics/ModuleLength
module ComponentHelpers
  def category_card(category, compact: false, inline: false)
    extra_classes = inline ? %w[inline] : []
    locals = {
      category:,
      compact:,
      extra_classes:,
    }
    render "components/category_card", locals
  end

  def render_project(project, show_categories: false, compact: false)
    render "components/project", project:, show_categories:, compact:
  end

  def project_links(project, compact: false)
    render "components/project/links", project:, compact:
  end

  def project_metrics(project, expanded_view: false, compact: false)
    render "components/project/metrics", project:, expanded_view:, compact:
  end

  def metrics_row(project, *metrics)
    metrics.sum("".html_safe) do |metric|
      render partial: "components/project/metric", locals: {
        key:   metric,
        value: project.public_send(metric),
        icon:  metric_icon(metric),
      }
    end
  end

  def project_link(label, url, icon:)
    render "components/project/link", label:, url:, icon:
  end

  def project_list(projects, title:, metrics: [], description: nil)
    render "components/project/list", projects:,
                                      title:,
                                      metrics:,
                                      description:
  end

  def project_health_tags(project)
    render "components/project_health_tags", project:
  end

  def project_health_tag(health_status)
    render "components/project_health_tag", status: health_status
  end

  def project_readme(readme)
    render "components/project/readme", readme:
  end

  def small_health_indicator(project)
    render "components/small_health_indicator", project:
  end

  def project_details_buttons(project)
    render "components/project/details_buttons", project:
  end

  def project_order_dropdown(order)
    render "components/project_order_dropdown", order:
  end

  def project_comparison(projects)
    render "components/project_comparison", projects:
  end

  def project_release_history(quarterly_release_counts, compact: false)
    return unless quarterly_release_counts.is_a?(Hash) && quarterly_release_counts.any?

    render "components/project_release_history", release_counts: quarterly_release_counts, compact:
  end

  RELEASE_INDICATOR_RANKS = {
    0 => "none",
    1 => "low",
    3 => "medium",
  }.freeze

  def quarterly_release_indicator(release_counts, year:, quarter:)
    count = release_counts["#{year}-#{quarter}"] || 0
    rank = RELEASE_INDICATOR_RANKS.find { |limit, _| count <= limit }&.last || "high"

    tooltip = "#{quarter.ordinalize} quarter #{year}: #{count} #{'release'.pluralize(count)}"

    tag.li class: "tooltip is-tooltip-bottom #{rank}", "data-tooltip" => tooltip
  end

  def trending_project_card(trend)
    render "components/trending_project_card", trend:
  end

  def section_heading(title, description: nil, help_path: nil, &)
    help_page = docs.find help_path
    render("components/section_heading", title:, description:, help_page:, &)
  end

  def project_display_picker(display_mode)
    render "components/project_display_picker", display_mode:
  end

  def rubygem_download_chart(name)
    return if name.blank?

    stats = Rubygem::DownloadStat::Timeseries.fetch name, :total_downloads, :absolute_change_month
    render "components/rubygem_download_chart", stats:
  end

  def line_chart(data, scale: "logarithmic")
    render "components/line_chart",
           keys:   data.keys,
           values: data.values,
           scale:
  end

  def bar_chart(data, small: false)
    render "components/bar_chart",
           keys:   data.keys,
           values: data.values,
           small:
  end

  def landing_hero(title:, image:, &)
    render("components/landing_hero", title:, image:, &)
  end

  def landing_feature(title:, image:, &)
    render("components/landing_feature", title:, image:, &)
  end

  def documentation_page(title, &)
    render("components/documentation_page", title:, &)
  end

  def component_example(heading, &)
    render("components/component_example", heading:, &)
  end
end
# rubocop:enable Metrics/ModuleLength
