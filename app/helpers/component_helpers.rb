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
    render partial: "components/category_card", locals: locals
  end

  def project_health_tags(project)
    render "components/project_health_tags", project: project
  end

  def project_health_tag(health_status)
    render "components/project_health_tag", status: health_status
  end

  def project_order_dropdown(order)
    render "components/project_order_dropdown", order: order
  end

  def line_chart(data)
    render "components/line_chart",
           keys:   data.keys,
           values: data.values
  end

  def bar_chart(data)
    render "components/bar_chart",
           keys:   data.keys,
           values: data.values
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
