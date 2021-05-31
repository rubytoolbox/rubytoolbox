# frozen_string_literal: true

#
# Controller for hosting static pages (mostly) for documentation via the HighVoltage gem
#
class PagesController < ApplicationController
  include HighVoltage::StaticPage

  private

  # See https://github.com/thoughtbot/high_voltage/issues/23#issuecomment-245631978
  def invalid_page
    render_not_found
  end
end
