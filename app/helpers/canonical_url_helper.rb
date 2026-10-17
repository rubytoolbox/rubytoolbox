# frozen_string_literal: true

module CanonicalUrlHelper
  # Query params that change which content a page shows. Everything else
  # (ordering, display mode, fork toggle, tracking params, ...) only produces
  # duplicates of the same page, which the canonical URL should collapse.
  CANONICAL_PARAMS = %w[q page].freeze

  def canonical_url
    query = request.query_parameters.slice(*CANONICAL_PARAMS).compact_blank
    query.delete("page") if query["page"] == "1"

    [request.base_url, request.path].join + (query.any? ? "?#{query.to_query}" : "")
  end
end
