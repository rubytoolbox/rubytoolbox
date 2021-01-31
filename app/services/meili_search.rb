# frozen_string_literal: true

#
# A simple HTTP client for interacting with [MeiliSearch](https://www.meilisearch.com/)
#
class MeiliSearch
  class UnknownResponseStatus < StandardError
    def initialize(response)
      super "Received unexpected response status #{response.status}"
    end
  end

  #
  # Returns an instance configured from MEILI_SEARCH_URL
  # environment variable, or nil if that is not set.
  #
  def self.client
    return if ENV["MEILI_SEARCH_URL"].blank?

    new url: ENV["MEILI_SEARCH_URL"].presence
  end

  attr_accessor :http
  private :http=

  def initialize(url:)
    self.http = prepare_http_client URI.parse(url)
  end

  def ranking_rules(index)
    settings(index).fetch("rankingRules")
  end

  def searchable_attributes(index)
    settings(index).fetch("searchableAttributes")
  end

  def displayed_attributes(index)
    settings(index).fetch("displayedAttributes")
  end

  def store_documents(index, documents)
    queue_index_update index, :documents, documents
  end

  def update_ranking_rules(index, rules)
    queue_index_update index, "settings/ranking-rules", rules
  end

  def update_searchable_attributes(index, attributes)
    queue_index_update index, "settings/searchable-attributes", attributes
  end

  def update_displayed_attributes(index, attributes)
    queue_index_update index, "settings/displayed-attributes", attributes
  end

  private

  def settings(index)
    response = http.get "/indexes/#{index}/settings"
    raise UnknownResponseStatus, response unless response.status == 200

    Oj.load response.body
  end

  def prepare_http_client(uri)
    client = HTTP
             .persistent("#{uri.scheme}://#{uri.host}")
             .timeout(connect: 2.seconds, write: 2.seconds, read: 2.seconds)

    if [uri.user, uri.password].any?
      client.basic_auth user: uri.user, pass: uri.password
    else
      client
    end
  end

  def queue_index_update(index, path, data)
    response = http.post "/indexes/#{index}/#{path}", json: data
    response.body.to_s
    raise UnknownResponseStatus, response unless response.status == 202

    true
  end
end
