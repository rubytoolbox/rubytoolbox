# frozen_string_literal: true

Kaminari.configure do |config|
  # in the test environment the limit is lower to avoid having to create
  # huge amounts of db records for simple test cases
  config.default_per_page = Rails.env.test? ? 3 : 20

  # config.max_per_page = nil
  config.window = 2
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  # config.page_method_name = :page
  # config.param_name = :page
  # config.params_on_first_page = false
end
