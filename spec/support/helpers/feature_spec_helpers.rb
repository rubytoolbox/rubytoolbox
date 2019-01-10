# frozen_string_literal: true

module FeatureSpecHelpers
  def listed_project_names
    page.find_all(".project h3").map(&:text)
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
end
