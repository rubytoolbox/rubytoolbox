# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # There's a few legacy routes being still frequently accessed i.e. for old RSS feeds,
  # or crawlers asking for crazy things like XML, which makes rails choke and exceptions
  # being reported, hence we catch them gracefully and just log the path for potential future
  # investigation
  rescue_from ActionController::UnknownFormat do
    logger.info "Unknown path/format requested #{request.path} / #{request.format}"
    render_not_found
  end

  private

  def render_not_found
    render file: Rails.root.join("public", "404.html"), layout: false, status: 404
  end
end
