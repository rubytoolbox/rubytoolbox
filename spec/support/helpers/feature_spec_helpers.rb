# frozen_string_literal: true

module FeatureSpecHelpers
  def listed_project_names
    if current_display_mode == "Table"
      page.find_all(".project-comparison tbody th").map(&:text)
    else
      page.find_all(".project h3").map(&:text)
    end
  end

  #
  # Since we're using custom js stuff here capybaras default synchronization
  # does not help us. In order to have the fastest-possible turnaround time,
  # this will retry at a high frequency until the maximum amount of tries is reached,
  # causing an exception to be raised.
  #
  # rubocop:disable Performance/RedundantBlockCall
  def wait_for(&block)
    Retriable.retriable tries: 15, base_interval: 0.05 do
      raise "Exceeded max retries while waiting for block to pass" unless block.call
    end
  end
  # rubocop:enable Performance/RedundantBlockCall

  def active_element
    page.evaluate_script "document.activeElement"
  end

  def order_by(button_label, expect_navigation: true)
    within ".project-order-dropdown" do
      page.find("button").hover
      click_on button_label
      expect(page).to have_text "Order by #{button_label}" if expect_navigation
    end
  end

  def current_display_mode
    page.find(".project-display-picker .is-active").text
  end

  def expect_display_mode(label) # rubocop:disable Metrics/AbcSize It's good enough :)
    within(".project-display-picker .is-active") do
      expect(page).to have_text(label)
    end

    case label.downcase.to_sym
    when :table
      expect(page).to have_selector(".project-comparison", count: 1)
    when :compact
      expect(page).to have_selector(".project-compact-cards", count: 1)
    end
  end

  def change_display_mode(label)
    within ".project-display-picker" do
      click_on label
    end
    expect_display_mode label
  end
end
