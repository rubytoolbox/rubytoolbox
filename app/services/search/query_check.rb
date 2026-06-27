# frozen_string_literal: true

class Search
  #
  # Decides whether a given search query is one we are actually willing to run
  # against the database.
  #
  # Bots spam the search with long CJK strings that pg_search expands into
  # pathological prefix tsqueries (every token becomes a ":*" prefix match,
  # ANDed together). These can run for tens of seconds and exhaust web dynos,
  # so we treat overly long or many-token queries as abusive and yield no
  # results instead of querying.
  #
  class QueryCheck
    # A genuine gem or category lookup is short, so anything substantially
    # longer is treated as abusive.
    MAX_QUERY_LENGTH = 30

    # pg_search turns every query token into a ":*" prefix match and ANDs them
    # together, so the query cost grows with the token count. The spam queries
    # pack a dozen or more comma-separated phrases, hence the cap.
    MAX_QUERY_TOKENS = 8

    attr_reader :query

    def initialize(query)
      @query = query
    end

    # Whether the query is acceptable to run: present and not abusive.
    def runnable?
      query.present? && !abusive?
    end

    # An abusive query is too long or carries too many tokens to be a
    # legitimate library search.
    def abusive?
      return false if query.blank?

      query.length > MAX_QUERY_LENGTH || token_count > MAX_QUERY_TOKENS
    end

    private

    # Counts word-character runs, mirroring how the text search parser
    # tokenizes the query. Punctuation (e.g. CJK 、，) separates tokens, so
    # spammy comma-separated phrase lists count as many tokens.
    def token_count
      query.scan(/[[:word:]]+/).length
    end
  end
end
